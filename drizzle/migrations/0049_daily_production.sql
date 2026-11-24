-- Daily Production Report (ZDPR, POST /zdpr_mis/report). One row per goods movement line (MBLNR + MJAHR + ZEILE).
CREATE TABLE IF NOT EXISTS public.daily_production (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  mblnr text NOT NULL,
  mjahr text NOT NULL DEFAULT '',
  zeile text NOT NULL DEFAULT '',
  werks text, zstage text, bwart text, matnr text, lgort text, charg text, meins text, aufnr text,
  budat date, maktx text, kdauf text, kdpos text, waers text, arbpl text, ktext_up text, stlbez text, name1 text,
  gltrp date, gstrp date, model text, range_txt text, type_txt text, comb text, cont_ref text, cell_type text, stage text,
  zkostl text, zkostl_name text, usnam text, uname text,
  menge numeric, dmbtr numeric, rate numeric, beams numeric, avg_count numeric, tmtrs numeric, age numeric, ah numeric, totah numeric,
  pos_plates numeric, neg_plates numeric, width numeric, stack_cell numeric, scrap_qty numeric, scrap_value numeric,
  raw jsonb NOT NULL DEFAULT '{}'::jsonb,
  source_endpoint text,
  synced_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT daily_production_line_key UNIQUE (mblnr, mjahr, zeile)
);
CREATE INDEX IF NOT EXISTS daily_production_budat_idx ON public.daily_production (budat);
CREATE INDEX IF NOT EXISTS daily_production_werks_idx ON public.daily_production (werks);
GRANT SELECT ON public.daily_production TO authenticated;
GRANT ALL ON public.daily_production TO service_role;
ALTER TABLE public.daily_production ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Daily production visible by access" ON public.daily_production;
CREATE POLICY "Daily production visible by access" ON public.daily_production FOR SELECT TO authenticated USING (
  (SELECT public.has_screen(auth.uid(), 'pp.daily-production-report')) AND ((SELECT public.current_access_unrestricted()) OR COALESCE(werks,'') = ANY ((SELECT public.current_access_plants())::text[])));
INSERT INTO public.sap_endpoints (name, module_key, description, endpoint_path, system_key, http_method, auth_type, body_template, posting_range, is_active)
SELECT 'Daily_Production_Report','common','ZDPR Daily Production Report','/zdpr_mis/report?sap-client=234','dev','POST','proxy',
  '{"WERKS":"1600","AUART":"ZSBD","FROMDT":"","TODT":"","MATNR":"","LGORT":""}','last1m',true
WHERE NOT EXISTS (SELECT 1 FROM public.sap_endpoints WHERE name='Daily_Production_Report');
NOTIFY pgrst, 'reload schema';