-- OTOMATİK YENİ EŞLEŞMELERİ OLUŞTUR
-- c d'nin talebi ile Caner Duru'nun portföyleri arasında 2 yeni eşleşme

-- EŞLEŞME 1: c d'nin talebi → Caner Duru'nun 1. portföyü
INSERT INTO matches (demand_id, portfolio_id, score, status, created_at)
SELECT 
    d.id as demand_id,
    po.id as portfolio_id,
    87 as score,
    'pending' as status,
    NOW() as created_at
FROM demands d
CROSS JOIN portfolios po
JOIN profiles dp ON d.user_id = dp.id
JOIN profiles pp ON po.user_id = pp.id
WHERE dp.email = 'caner@brokerlink.com'
  AND pp.email = 'test@brokerlink.com'
ORDER BY po.created_at DESC
LIMIT 1;

-- EŞLEŞME 2: c d'nin talebi → Caner Duru'nun 2. portföyü
INSERT INTO matches (demand_id, portfolio_id, score, status, created_at)
SELECT 
    d.id as demand_id,
    po.id as portfolio_id,
    84 as score,
    'pending' as status,
    NOW() as created_at
FROM demands d
CROSS JOIN portfolios po
JOIN profiles dp ON d.user_id = dp.id
JOIN profiles pp ON po.user_id = pp.id
WHERE dp.email = 'caner@brokerlink.com'
  AND pp.email = 'test@brokerlink.com'
ORDER BY po.created_at DESC
LIMIT 1 OFFSET 1;

-- KONTROL: Yeni oluşturulan eşleşmeleri göster
SELECT 
    m.id,
    m.score,
    m.status,
    d.title as demand_title,
    dp.name as demand_owner,
    p.title as portfolio_title,
    pp.name as portfolio_owner,
    m.created_at
FROM matches m
JOIN demands d ON m.demand_id = d.id
JOIN profiles dp ON d.user_id = dp.id
JOIN portfolios p ON m.portfolio_id = p.id
JOIN profiles pp ON p.user_id = pp.id
WHERE m.status = 'pending'
ORDER BY m.created_at DESC
LIMIT 5;
