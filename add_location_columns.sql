-- ============================================================
-- ADD city AND location COLUMNS (if missing)
-- Run in Supabase SQL Editor
-- ============================================================

-- Add 'city' column to demands table (if not exists)
ALTER TABLE public.demands ADD COLUMN IF NOT EXISTS city text;

-- Add 'city' column to portfolios table (if not exists)
ALTER TABLE public.portfolios ADD COLUMN IF NOT EXISTS city text;

-- Add 'location' column to demands table (for ilçe, if not exists)
ALTER TABLE public.demands ADD COLUMN IF NOT EXISTS location text;

-- Verify columns were added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name IN ('demands', 'portfolios')
AND column_name IN ('city', 'location')
ORDER BY table_name, column_name;
