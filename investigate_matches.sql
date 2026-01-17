-- Tüm eşleşmeleri incele ve fake olanları tespit et
-- Gerçek eşleşmeler: AI tarafından otomatik oluşturulanlar veya manuel onaylananlar
-- Fake eşleşmeler: Test için manuel SQL ile eklenenler

-- 1. Tüm eşleşmeleri listele
SELECT 
    m.id,
    m.status,
    m.score,
    m.created_at,
    -- Demand bilgileri
    d.title as demand_title,
    d.user_id as demand_owner,
    dp.name as demand_owner_name,
    -- Portfolio bilgileri
    p.title as portfolio_title,
    p.user_id as portfolio_owner,
    pp.name as portfolio_owner_name
FROM matches m
LEFT JOIN demands d ON m.demand_id = d.id
LEFT JOIN profiles dp ON d.user_id = dp.id
LEFT JOIN portfolios p ON m.portfolio_id = p.id
LEFT JOIN profiles pp ON p.user_id = pp.id
ORDER BY m.created_at DESC;

-- 2. Kullanıcı başına eşleşme sayısı
SELECT 
    COALESCE(dp.name, 'Unknown') as demand_owner,
    COALESCE(pp.name, 'Unknown') as portfolio_owner,
    COUNT(*) as match_count
FROM matches m
LEFT JOIN demands d ON m.demand_id = d.id
LEFT JOIN profiles dp ON d.user_id = dp.id
LEFT JOIN portfolios p ON m.portfolio_id = p.id
LEFT JOIN profiles pp ON p.user_id = pp.id
GROUP BY demand_owner, portfolio_owner
ORDER BY match_count DESC;

-- 3. Mert Yılmaz ile olan eşleşmeler (test verileri olabilir)
SELECT 
    m.id,
    m.status,
    d.title as demand_title,
    p.title as portfolio_title,
    m.created_at
FROM matches m
LEFT JOIN demands d ON m.demand_id = d.id
LEFT JOIN profiles dp ON d.user_id = dp.id
LEFT JOIN portfolios p ON m.portfolio_id = p.id
LEFT JOIN profiles pp ON p.user_id = pp.id
WHERE dp.name = 'Mert Yılmaz' OR pp.name = 'Mert Yılmaz'
ORDER BY m.created_at DESC;
