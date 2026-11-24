CREATE OR REPLACE FUNCTION public.mws_num(_v text) RETURNS numeric LANGUAGE sql IMMUTABLE AS $$
  SELECT coalesce(nullif(regexp_replace(coalesce(_v,''), '[^0-9.\-]', '', 'g'), '')::numeric, 0)
$$;

CREATE OR REPLACE FUNCTION public.month_wise_stock_summary()
RETURNS jsonb LANGUAGE sql STABLE SECURITY INVOKER SET search_path TO 'public' SET statement_timeout TO '60s' AS $$
  SELECT coalesce(jsonb_agg(jsonb_build_object('id', concat_ws('|', year, month, vc, pc, pl), 'month', month, 'year', year,
    'data', jsonb_build_object('ValCl', vc, 'Profit Centre', pc, 'Plnt', pl, 'CB Qty', q::text, 'CB Val', v::text))), '[]'::jsonb)
  FROM (
    SELECT month, year, trim(coalesce(data->>'ValCl','')) vc, trim(coalesce(data->>'Profit Centre','')) pc, trim(coalesce(data->>'Plnt','')) pl,
      sum(public.mws_num(data->>'CB Qty')) q, sum(public.mws_num(data->>'CB Val')) v
    FROM public.month_wise_upload
    WHERE trim(coalesce(data->>'ValCl','')) <> ''
    GROUP BY 1,2,3,4,5
  ) t;
$$;

CREATE OR REPLACE FUNCTION public.month_wise_stock_materials(_mats text[] DEFAULT '{}')
RETURNS jsonb LANGUAGE sql STABLE SECURITY INVOKER SET search_path TO 'public' SET statement_timeout TO '60s' AS $$
  WITH g AS (
    SELECT month, year, trim(coalesce(data->>'ValCl','')) vc, trim(coalesce(data->>'Profit Centre','')) pc, trim(coalesce(data->>'Plnt','')) pl,
      trim(coalesce(data->>'Material','')) mat, max(trim(coalesce(data->>'Material Description',''))) md, max(trim(coalesce(data->>'BUn',''))) un,
      sum(public.mws_num(data->>'CB Qty')) q, sum(public.mws_num(data->>'CB Val')) v
    FROM public.month_wise_upload
    WHERE trim(coalesce(data->>'Material','')) <> ''
    GROUP BY 1,2,3,4,5,6
  ), top AS (
    SELECT month, year, mat FROM (
      SELECT month, year, mat, row_number() OVER (PARTITION BY month, year ORDER BY sum(v) DESC) rn FROM g GROUP BY 1,2,3
    ) x WHERE rn <= 40
  )
  SELECT coalesce(jsonb_agg(jsonb_build_object('id', concat_ws('|', g.year, g.month, vc, pc, pl, g.mat), 'month', g.month, 'year', g.year,
    'data', jsonb_build_object('ValCl', vc, 'Profit Centre', pc, 'Plnt', pl, 'Material', g.mat, 'Material Description', md, 'BUn', un, 'CB Qty', q::text, 'CB Val', v::text))), '[]'::jsonb)
  FROM g
  WHERE EXISTS (SELECT 1 FROM top WHERE top.month = g.month AND top.year = g.year AND top.mat = g.mat)
     OR upper(regexp_replace(g.mat, '^0+(?=.)', '')) = ANY (coalesce(_mats, '{}'));
$$;

CREATE OR REPLACE FUNCTION public.month_wise_stock_kpis()
RETURNS jsonb LANGUAGE sql STABLE SECURITY INVOKER SET search_path TO 'public' SET statement_timeout TO '60s' AS $$
  SELECT coalesce(jsonb_agg(jsonb_build_object('month', month, 'year', year, 'vc', vc, 'v', v)), '[]'::jsonb)
  FROM (
    SELECT month, year, trim(coalesce(data->>'ValCl','')) vc, sum(public.mws_num(data->>'CB Val')) v
    FROM public.month_wise_upload
    WHERE trim(coalesce(data->>'ValCl','')) <> ''
    GROUP BY 1,2,3
  ) t;
$$;

GRANT EXECUTE ON FUNCTION public.mws_num(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.month_wise_stock_summary() TO authenticated;
GRANT EXECUTE ON FUNCTION public.month_wise_stock_materials(text[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.month_wise_stock_kpis() TO authenticated;
NOTIFY pgrst, 'reload schema';