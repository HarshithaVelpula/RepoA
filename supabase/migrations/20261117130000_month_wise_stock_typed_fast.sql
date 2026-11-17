ALTER TABLE public.month_wise_upload
  ADD COLUMN IF NOT EXISTS val_class text GENERATED ALWAYS AS (trim(coalesce(data->>'ValCl',''))) STORED,
  ADD COLUMN IF NOT EXISTS profit_centre text GENERATED ALWAYS AS (trim(coalesce(data->>'Profit Centre',''))) STORED,
  ADD COLUMN IF NOT EXISTS plant text GENERATED ALWAYS AS (trim(coalesce(data->>'Plnt',''))) STORED,
  ADD COLUMN IF NOT EXISTS material text GENERATED ALWAYS AS (trim(coalesce(data->>'Material',''))) STORED,
  ADD COLUMN IF NOT EXISTS cb_qty numeric GENERATED ALWAYS AS (public.mws_num(data->>'CB Qty')) STORED,
  ADD COLUMN IF NOT EXISTS cb_val numeric GENERATED ALWAYS AS (public.mws_num(data->>'CB Val')) STORED;

CREATE INDEX IF NOT EXISTS month_wise_upload_kpi_idx ON public.month_wise_upload (year, month, val_class) INCLUDE (cb_val, plant, profit_centre);

DROP POLICY IF EXISTS month_wise_upload_stock_read ON public.month_wise_upload;
CREATE POLICY month_wise_upload_stock_read ON public.month_wise_upload FOR SELECT TO authenticated
USING (
  (SELECT public.has_screen(auth.uid(), 'inv.month-wise-stock'))
  AND ((SELECT public.current_access_unrestricted())
    OR plant = ANY ((SELECT public.current_access_plants())::text[])
    OR profit_centre = ANY ((SELECT public.current_access_profit_centers())::text[]))
);

CREATE OR REPLACE FUNCTION public.mws_access(OUT ok boolean, OUT unrestricted boolean, OUT plants text[], OUT pcs text[])
LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO 'public' AS $$
  SELECT public.is_data_admin(auth.uid()) OR public.has_screen(auth.uid(), 'inv.month-wise-stock') OR public.has_screen(auth.uid(), 'tables.month-wise-upload'),
         public.current_access_unrestricted(), public.current_access_plants(), public.current_access_profit_centers();
$$;

CREATE OR REPLACE FUNCTION public.month_wise_stock_kpis()
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO 'public' SET statement_timeout TO '60s' AS $$
DECLARE a record; res jsonb;
BEGIN
  SELECT * INTO a FROM public.mws_access();
  IF NOT a.ok THEN RAISE EXCEPTION 'Access denied'; END IF;
  SELECT coalesce(jsonb_agg(jsonb_build_object('month', month, 'year', year, 'vc', vc, 'v', v)), '[]'::jsonb) INTO res
  FROM (
    SELECT month, year, val_class vc, sum(cb_val) v FROM public.month_wise_upload
    WHERE val_class <> '' AND (a.unrestricted OR plant = ANY (a.plants) OR profit_centre = ANY (a.pcs))
    GROUP BY 1,2,3
  ) t;
  RETURN res;
END $$;

CREATE OR REPLACE FUNCTION public.month_wise_stock_summary()
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO 'public' SET statement_timeout TO '60s' AS $$
DECLARE a record; res jsonb;
BEGIN
  SELECT * INTO a FROM public.mws_access();
  IF NOT a.ok THEN RAISE EXCEPTION 'Access denied'; END IF;
  SELECT coalesce(jsonb_agg(jsonb_build_object('id', concat_ws('|', year, month, vc, pc, pl), 'month', month, 'year', year,
    'data', jsonb_build_object('ValCl', vc, 'Profit Centre', pc, 'Plnt', pl, 'CB Qty', q::text, 'CB Val', v::text))), '[]'::jsonb) INTO res
  FROM (
    SELECT month, year, val_class vc, profit_centre pc, plant pl, sum(cb_qty) q, sum(cb_val) v
    FROM public.month_wise_upload
    WHERE val_class <> '' AND (a.unrestricted OR plant = ANY (a.plants) OR profit_centre = ANY (a.pcs))
    GROUP BY 1,2,3,4,5
  ) t;
  RETURN res;
END $$;

CREATE OR REPLACE FUNCTION public.month_wise_stock_materials(_mats text[] DEFAULT '{}'::text[])
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO 'public' SET statement_timeout TO '60s' AS $$
DECLARE a record; res jsonb;
BEGIN
  SELECT * INTO a FROM public.mws_access();
  IF NOT a.ok THEN RAISE EXCEPTION 'Access denied'; END IF;
  WITH g AS (
    SELECT month, year, val_class vc, profit_centre pc, plant pl, material mat,
      max(trim(coalesce(data->>'Material Description',''))) md, max(trim(coalesce(data->>'BUn',''))) un,
      sum(cb_qty) q, sum(cb_val) v
    FROM public.month_wise_upload
    WHERE material <> '' AND (a.unrestricted OR plant = ANY (a.plants) OR profit_centre = ANY (a.pcs))
    GROUP BY 1,2,3,4,5,6
  ), top AS (
    SELECT month, year, mat FROM (
      SELECT month, year, mat, row_number() OVER (PARTITION BY month, year ORDER BY sum(v) DESC) rn FROM g GROUP BY 1,2,3
    ) x WHERE rn <= 40
  )
  SELECT coalesce(jsonb_agg(jsonb_build_object('id', concat_ws('|', g.year, g.month, vc, pc, pl, g.mat), 'month', g.month, 'year', g.year,
    'data', jsonb_build_object('ValCl', vc, 'Profit Centre', pc, 'Plnt', pl, 'Material', g.mat, 'Material Description', md, 'BUn', un, 'CB Qty', q::text, 'CB Val', v::text))), '[]'::jsonb) INTO res
  FROM g
  WHERE EXISTS (SELECT 1 FROM top WHERE top.month = g.month AND top.year = g.year AND top.mat = g.mat)
     OR upper(regexp_replace(g.mat, '^0+(?=.)', '')) = ANY (coalesce(_mats, '{}'));
  RETURN res;
END $$;

REVOKE ALL ON FUNCTION public.mws_access() FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.month_wise_stock_kpis() FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.month_wise_stock_summary() FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.month_wise_stock_materials(text[]) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.mws_access() TO authenticated;
GRANT EXECUTE ON FUNCTION public.month_wise_stock_kpis() TO authenticated;
GRANT EXECUTE ON FUNCTION public.month_wise_stock_summary() TO authenticated;
GRANT EXECUTE ON FUNCTION public.month_wise_stock_materials(text[]) TO authenticated;
NOTIFY pgrst, 'reload schema';