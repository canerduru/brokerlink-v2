-- ============================================
-- Blocking Feature - SQL Migration
-- ============================================
-- Bu SQL dosyasını Supabase SQL Editor'da çalıştırın.
-- 1. blocked_users tablosu oluşturur
-- 2. RLS policies ekler
-- 3. get_network_demands() fonksiyonunu günceller
-- 4. get_network_portfolios() fonksiyonunu günceller
-- ============================================

-- 1. BLOCKED USERS TABLOSU
CREATE TABLE IF NOT EXISTS blocked_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blocker_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    blocked_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(blocker_id, blocked_id)
);

-- 2. RLS POLICIES
ALTER TABLE blocked_users ENABLE ROW LEVEL SECURITY;

-- Kullanıcı sadece kendi engellerini görebilir
CREATE POLICY "Users can view own blocks"
    ON blocked_users FOR SELECT
    USING (blocker_id = auth.uid());

-- Kullanıcı engel ekleyebilir
CREATE POLICY "Users can insert own blocks"
    ON blocked_users FOR INSERT
    WITH CHECK (blocker_id = auth.uid());

-- Kullanıcı kendi engellerini kaldırabilir
CREATE POLICY "Users can delete own blocks"
    ON blocked_users FOR DELETE
    USING (blocker_id = auth.uid());

-- 3. GET_NETWORK_DEMANDS GÜNCELLEME
-- Önce eski fonksiyonu kaldır (return type değişikliği için gerekli)
DROP FUNCTION IF EXISTS get_network_demands();
-- Engellenen kullanıcıların talepleri gözükmez
CREATE OR REPLACE FUNCTION get_network_demands()
RETURNS TABLE (
    id BIGINT,
    user_id UUID,
    title TEXT,
    budget NUMERIC,
    max_budget NUMERIC,
    district TEXT,
    city TEXT,
    type TEXT,
    created_at TIMESTAMPTZ,
    broker_name TEXT,
    broker_avatar_url TEXT,
    broker_company TEXT,
    broker_title TEXT,
    category TEXT,
    rooms TEXT,
    is_urgent BOOLEAN,
    status TEXT
) LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN QUERY
  SELECT 
    d.id,
    d.user_id,
    d.title,
    d.budget,
    d.max_budget,
    d.district,
    d.city,
    d.type,
    d.created_at,
    p.name as broker_name,
    p.avatar_url as broker_avatar_url,
    p.company as broker_company,
    p.title as broker_title,
    d.category,
    d.rooms,
    d.is_urgent,
    d.status
  FROM demands d
  INNER JOIN profiles p ON d.user_id = p.id
  WHERE d.user_id IN (
    SELECT receiver_id FROM network_connections 
    WHERE requester_id = auth.uid() AND network_connections.status = 'accepted'
    
    UNION
    
    SELECT requester_id FROM network_connections 
    WHERE receiver_id = auth.uid() AND network_connections.status = 'accepted'
  )
  AND d.user_id != auth.uid()
  AND d.status = 'active'
  -- BLOCKED USERS FİLTRESİ
  AND d.user_id NOT IN (
    SELECT blocked_id FROM blocked_users WHERE blocker_id = auth.uid()
  )
  ORDER BY d.created_at DESC;
END;
$$;

-- 4. GET_NETWORK_PORTFOLIOS GÜNCELLEME
-- Önce eski fonksiyonu kaldır (return type değişikliği için gerekli)
DROP FUNCTION IF EXISTS get_network_portfolios();
-- Engellenen kullanıcıların portföyleri gözükmez
CREATE OR REPLACE FUNCTION get_network_portfolios()
RETURNS TABLE (
    id BIGINT,
    user_id UUID,
    title TEXT,
    price NUMERIC,
    district TEXT,
    city TEXT,
    type TEXT,
    category TEXT,
    rooms TEXT,
    area TEXT,
    age TEXT,
    image_url TEXT,
    created_at TIMESTAMPTZ,
    broker_name TEXT,
    broker_avatar_url TEXT,
    broker_company TEXT,
    broker_title TEXT
) LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN QUERY
  SELECT 
    po.id,
    po.user_id,
    po.title,
    po.price,
    po.district,
    po.city,
    po.type,
    po.category,
    po.rooms,
    po.area,
    po.age,
    po.image_url,
    po.created_at,
    p.name as broker_name,
    p.avatar_url as broker_avatar_url,
    p.company as broker_company,
    p.title as broker_title
  FROM portfolios po
  INNER JOIN profiles p ON po.user_id = p.id
  WHERE po.user_id IN (
    SELECT receiver_id FROM network_connections 
    WHERE requester_id = auth.uid() AND network_connections.status = 'accepted'
    
    UNION
    
    SELECT requester_id FROM network_connections 
    WHERE receiver_id = auth.uid() AND network_connections.status = 'accepted'
  )
  AND po.user_id != auth.uid()
  -- BLOCKED USERS FİLTRESİ
  AND po.user_id NOT IN (
    SELECT blocked_id FROM blocked_users WHERE blocker_id = auth.uid()
  )
  ORDER BY po.created_at DESC;
END;
$$;

-- SONUÇ
SELECT 'Blocking feature installed! blocked_users table created, RPC functions updated.' as status;
