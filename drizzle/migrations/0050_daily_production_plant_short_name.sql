ALTER TABLE public.daily_production ADD COLUMN IF NOT EXISTS plant_short_name text;
UPDATE public.daily_production SET plant_short_name = NULLIF(trim(COALESCE(raw->>'PLANT_SHORT_NAME', raw->>'PLANTSHORTNAME')), '') WHERE plant_short_name IS NULL;
NOTIFY pgrst, 'reload schema';