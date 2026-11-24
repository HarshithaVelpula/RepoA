-- Current Stock: SAP now sends descriptive keys (UNRESTRICTED_VALUE, QC_VALUE, BLOCKED_VALUE, WBWBEST, ...).
ALTER TABLE public.current_stock
  ADD COLUMN IF NOT EXISTS matkl text, ADD COLUMN IF NOT EXISTS bklas text, ADD COLUMN IF NOT EXISTS bkbez text,
  ADD COLUMN IF NOT EXISTS valclass_sn text, ADD COLUMN IF NOT EXISTS hwaer text,
  ADD COLUMN IF NOT EXISTS mbwbest numeric, ADD COLUMN IF NOT EXISTS wbwbest numeric;

UPDATE public.current_stock SET
  labst = COALESCE(NULLIF(raw->>'UNRESTRICTED_QTY','')::numeric, labst),
  wlabs = COALESCE(NULLIF(raw->>'UNRESTRICTED_VALUE','')::numeric, wlabs),
  insme = COALESCE(NULLIF(raw->>'QC_QTY','')::numeric, insme),
  winsm = COALESCE(NULLIF(raw->>'QC_VALUE','')::numeric, winsm),
  speme = COALESCE(NULLIF(raw->>'BLOCKED_QTY','')::numeric, speme),
  wspem = COALESCE(NULLIF(raw->>'BLOCKED_VALUE','')::numeric, wspem),
  mbwbest = NULLIF(raw->>'MBWBEST','')::numeric, wbwbest = NULLIF(raw->>'WBWBEST','')::numeric,
  matkl = raw->>'MATKL', bklas = raw->>'BKLAS', bkbez = raw->>'BKBEZ', valclass_sn = raw->>'VALCLASS_SN', hwaer = raw->>'HWAER'
WHERE raw ? 'UNRESTRICTED_VALUE' OR raw ? 'WBWBEST';

UPDATE public.current_stock SET wlabs = wbwbest, labst = COALESCE(NULLIF(labst,0), mbwbest)
WHERE COALESCE(wlabs,0)=0 AND COALESCE(winsm,0)=0 AND COALESCE(wspem,0)=0 AND COALESCE(wbwbest,0)<>0;

NOTIFY pgrst, 'reload schema';