-- ============================================
-- Network Portfolios RPC Function
-- ============================================
-- Bu fonksiyon kullanıcının ağındaki (bağlantılı olduğu) 
-- diğer brokerların portföylerini güvenli bir şekilde getirir.

-- Önce eski fonksiyonu sil (eğer varsa)
DROP FUNCTION IF EXISTS get_network_portfolios();

CREATE OR REPLACE FUNCTION get_network_portfolios()
RETURNS TABLE (
  id bigint,
  user_id uuid,
  title text,
  price numeric,
  rooms text,
  district text,
  city text,
  type text,
  created_at timestamptz,
  broker_name text,
  broker_avatar_url text,
  broker_company text,
  broker_title text
) 
LANGUAGE plpgsql 
SECURITY DEFINER 
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.user_id,
    p.title,
    p.price,
    p.rooms,
    p.district,
    p.city,
    p.type,
    p.created_at,
    pr.name as broker_name,
    pr.avatar_url as broker_avatar_url,
    pr.company as broker_company,
    pr.title as broker_title
  FROM portfolios p
  INNER JOIN profiles pr ON p.user_id = pr.id
  WHERE p.user_id IN (
    -- Kullanıcının başlattığı onaylanmış bağlantılar
    SELECT receiver_id FROM network_connections 
    WHERE requester_id = auth.uid() AND status = 'accepted'
    
    UNION
    
    -- Kullanıcıya gelen onaylanmış bağlantılar
    SELECT requester_id FROM network_connections 
    WHERE receiver_id = auth.uid() AND status = 'accepted'
  )
  AND p.user_id != auth.uid() -- Kendi portföylerini gösterme
  ORDER BY p.created_at DESC
  LIMIT 100; -- Performans için limit
END;
$$;

-- ============================================
-- Tamamlandı!
-- ============================================
-- Bu SQL'i Supabase SQL Editor'da çalıştırın.
