-- =====================================================
-- ADMIN PANELİ: BÖLGE DAĞILIM RPC FONKSİYONLARI
-- Supabase SQL editöründe çalıştırın
-- =====================================================

-- 1. Bölge başına aktif broker sayısı
CREATE OR REPLACE FUNCTION admin_get_broker_distribution()
RETURNS TABLE(city text, district text, broker_count bigint) AS $$
  SELECT 
    area->>'city' AS city,
    area->>'district' AS district,
    COUNT(DISTINCT profiles.id) AS broker_count
  FROM profiles,
    jsonb_array_elements(service_areas) AS area
  WHERE service_areas IS NOT NULL AND jsonb_array_length(service_areas) > 0
  GROUP BY city, district
  ORDER BY broker_count DESC
  LIMIT 10;
$$ LANGUAGE sql SECURITY DEFINER;

-- 2. Şehir başına portföy sayısı
CREATE OR REPLACE FUNCTION admin_get_portfolio_distribution()
RETURNS TABLE(city text, portfolio_count bigint) AS $$
  SELECT 
    city,
    COUNT(*) AS portfolio_count
  FROM portfolios
  WHERE city IS NOT NULL AND city != ''
  GROUP BY city
  ORDER BY portfolio_count DESC
  LIMIT 10;
$$ LANGUAGE sql SECURITY DEFINER;

-- 3. Şehir başına talep sayısı
CREATE OR REPLACE FUNCTION admin_get_demand_distribution()
RETURNS TABLE(city text, demand_count bigint) AS $$
  SELECT 
    city,
    COUNT(*) AS demand_count
  FROM demands
  WHERE city IS NOT NULL AND city != ''
  GROUP BY city
  ORDER BY demand_count DESC
  LIMIT 10;
$$ LANGUAGE sql SECURITY DEFINER;

-- Erişim izinleri
GRANT EXECUTE ON FUNCTION admin_get_broker_distribution() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION admin_get_portfolio_distribution() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION admin_get_demand_distribution() TO anon, authenticated;
