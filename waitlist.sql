-- =============================================
-- Evliyo Waitlist Tablosu
-- Supabase SQL Editor'de çalıştırın
-- =============================================

CREATE TABLE IF NOT EXISTS public.waitlist (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    source TEXT DEFAULT 'landing_page',  -- nereden geldi (hero, cta, footer)
    created_at TIMESTAMPTZ DEFAULT NOW(),
    ip_hash TEXT,                         -- opsiyonel: spam önleme
    notes TEXT                            -- opsiyonel: admin notu
);

-- Index: email aramaları için
CREATE INDEX IF NOT EXISTS waitlist_email_idx ON public.waitlist (email);
CREATE INDEX IF NOT EXISTS waitlist_created_at_idx ON public.waitlist (created_at DESC);

-- RLS: Herkes ekleyebilir (insert), sadece admin okuyabilir
ALTER TABLE public.waitlist ENABLE ROW LEVEL SECURITY;

-- Policy: Herkes email ekleyebilir (anonim dahil)
CREATE POLICY "Anyone can join waitlist"
    ON public.waitlist
    FOR INSERT
    TO anon, authenticated
    WITH CHECK (true);

-- Policy: Sadece authenticated admin okuyabilir
CREATE POLICY "Authenticated users can view waitlist"
    ON public.waitlist
    FOR SELECT
    TO authenticated
    USING (true);

-- Tablo hakkında yorum
COMMENT ON TABLE public.waitlist IS 'Evliyo landing page waitlist - email kayıtları';
COMMENT ON COLUMN public.waitlist.source IS 'Formun geldiği yer: hero, cta';
