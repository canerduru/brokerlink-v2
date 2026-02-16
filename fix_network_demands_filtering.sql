-- ============================================
-- Fix Network Demands Filtering
-- ============================================
-- Bu SQL dosyası get_network_demands fonksiyonunu düzeltir.
-- Sadece KABUL EDİLMİŞ (status = 'accepted') bağlantılardan
-- gelen talepleri gösterir.

-- Önce mevcut fonksiyonu sil
DROP FUNCTION IF EXISTS get_network_demands();

-- Yeni fonksiyonu oluştur (Sadece arkadaş eklediğiniz kişilerin talepleri)
CREATE OR REPLACE FUNCTION get_network_demands()
RETURNS TABLE (
  id bigint,
  user_id uuid,
  title text,
  budget numeric,
  max_budget numeric,
  district text,
  city text,
  type text,
  created_at timestamptz,
  broker_name text,
  broker_avatar_url text,
  broker_company text,
  broker_title text,
  category text,
  rooms text,
  is_urgent boolean,
  status text
) 
LANGUAGE plpgsql 
SECURITY DEFINER 
AS $$
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
    -- Kullanıcının başlattığı ve KABUL EDİLMİŞ bağlantılar
    SELECT receiver_id FROM network_connections 
    WHERE requester_id = auth.uid() AND status = 'accepted'
    
    UNION
    
    -- Kullanıcıya gelen ve KABUL EDİLMİŞ bağlantılar
    SELECT requester_id FROM network_connections 
    WHERE receiver_id = auth.uid() AND status = 'accepted'
  )
  AND d.user_id != auth.uid() -- Kendi taleplerini gösterme
  AND d.status = 'active' -- Sadece aktif talepler
  ORDER BY d.created_at DESC
  LIMIT 100; -- Performans için limit
END;
$$;

-- ============================================
-- Tamamlandı!
-- ============================================
-- Bu SQL'i Supabase SQL Editor'da çalıştırın.

SELECT 'Network Demands filtering fixed! Only accepted connections will be shown.' as status;
