CREATE OR REPLACE FUNCTION public.month_wise_stock_totals()
RETURNS jsonb
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path TO 'public'
SET statement_timeout TO '60s'
AS $$
  SELECT coalesce(jsonb_agg(jsonb_build_object('id', concat_ws('|', year, month, vc, pc, pl, mat), 'month', month, 'year', year,
    'data', jsonb_build_object('ValCl', vc, 'Profit Centre', pc, 'Plnt', pl, 'Material', mat, 'Material Description', md, 'Matl Group', mg, 'BUn', un, 'CB Qty', q::text, 'CB Val', v::text))), '[]'::jsonb)
  FROM (
    SELECT month, year, trim(coalesce(data->>'ValCl','')) vc, trim(coalesce(data->>'Profit Centre','')) pc, trim(coalesce(data->>'Plnt','')) pl,
      trim(coalesce(data->>'Material','')) mat, max(trim(coalesce(data->>'Material Description',''))) md, max(trim(coalesce(data->>'Matl Group',''))) mg, max(trim(coalesce(data->>'BUn',''))) un,
      sum(coalesce(nullif(regexp_replace(coalesce(data->>'CB Qty',''), '[^0-9.\-]', '', 'g'), '')::numeric, 0)) q,
      sum(coalesce(nullif(regexp_replace(coalesce(data->>'CB Val',''), '[^0-9.\-]', '', 'g'), '')::numeric, 0)) v
    FROM public.month_wise_upload
    WHERE trim(coalesce(data->>'ValCl','')) <> '' OR trim(coalesce(data->>'Material','')) <> ''
    GROUP BY 1,2,3,4,5,6
  ) t;
$$;
GRANT EXECUTE ON FUNCTION public.month_wise_stock_totals() TO authenticated;
NOTIFY pgrst, 'reload schema';