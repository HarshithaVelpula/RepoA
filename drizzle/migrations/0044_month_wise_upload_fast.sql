CREATE INDEX IF NOT EXISTS month_wise_upload_period_id_idx ON public.month_wise_upload (year, month, id);
DROP POLICY IF EXISTS month_wise_upload_all ON public.month_wise_upload;
CREATE POLICY month_wise_upload_all ON public.month_wise_upload FOR ALL TO authenticated
  USING ((SELECT public.is_data_admin(auth.uid())) OR (SELECT public.has_screen(auth.uid(), 'tables.month-wise-upload')))
  WITH CHECK ((SELECT public.is_data_admin(auth.uid())) OR (SELECT public.has_screen(auth.uid(), 'tables.month-wise-upload')));

CREATE OR REPLACE FUNCTION public.mwu_can_manage() RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO 'public'
AS $$ SELECT public.is_data_admin(auth.uid()) OR public.has_screen(auth.uid(), 'tables.month-wise-upload'); $$;

CREATE OR REPLACE FUNCTION public.delete_month_wise_upload(_month integer, _year integer)
RETURNS integer LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public' SET statement_timeout TO '120s'
AS $$
DECLARE n integer;
BEGIN
  IF NOT public.mwu_can_manage() THEN RAISE EXCEPTION 'Access denied'; END IF;
  DELETE FROM public.month_wise_upload WHERE year = _year AND month = _month;
  GET DIAGNOSTICS n = ROW_COUNT;
  RETURN n;
END $$;

CREATE OR REPLACE FUNCTION public.month_wise_upload_page(_month integer, _year integer, _search text, _offset integer, _limit integer)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO 'public' SET statement_timeout TO '60s'
AS $$
DECLARE s text := nullif(trim(coalesce(_search, '')), ''); res jsonb;
BEGIN
  IF NOT public.mwu_can_manage() THEN RAISE EXCEPTION 'Access denied'; END IF;
  WITH base AS (
    SELECT id, month, year, data, created_at, updated_at FROM public.month_wise_upload
    WHERE year = _year AND month = _month AND (s IS NULL OR data::text ILIKE '%' || s || '%')
  )
  SELECT jsonb_build_object(
    'total', (SELECT count(*) FROM base),
    'all_total', (SELECT count(*) FROM public.month_wise_upload WHERE year = _year AND month = _month),
    'created', (SELECT min(created_at) FROM public.month_wise_upload WHERE year = _year AND month = _month),
    'updated', (SELECT max(updated_at) FROM public.month_wise_upload WHERE year = _year AND month = _month),
    'columns', (SELECT coalesce(jsonb_agg(DISTINCT k), '[]'::jsonb) FROM (SELECT data FROM public.month_wise_upload WHERE year = _year AND month = _month LIMIT 200) t, jsonb_object_keys(t.data) k),
    'rows', (SELECT coalesce(jsonb_agg(to_jsonb(b) ORDER BY b.id), '[]'::jsonb) FROM (SELECT * FROM base ORDER BY id OFFSET greatest(_offset,0) LIMIT least(greatest(_limit,1),1000)) b)
  ) INTO res;
  RETURN res;
END $$;

GRANT EXECUTE ON FUNCTION public.mwu_can_manage() TO authenticated;
GRANT EXECUTE ON FUNCTION public.delete_month_wise_upload(integer, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.month_wise_upload_page(integer, integer, text, integer, integer) TO authenticated;
NOTIFY pgrst, 'reload schema';