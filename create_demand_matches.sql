-- CANER DURU'NUN TALEPLERİNE EŞLEŞEN PORTFÖYLER OLUŞTUR
-- Senin taleplerin → Mert Yılmaz'ın portföyleri

-- EŞLEŞME 1: Caner Duru'nun 1. talebi → Mert Yılmaz'ın 1. portföyü
INSERT INTO matches (demand_id, portfolio_id, score, status, created_at)
SELECT 
    d.id as demand_id,
    po.id as portfolio_id,
    89 as score,
    'pending' as status,
    NOW() as created_at
FROM demands d
CROSS JOIN portfolios po
JOIN profiles dp ON d.user_id = dp.id
JOIN profiles pp ON po.user_id = pp.id
WHERE dp.email = 'test@brokerlink.com'
  AND pp.email = 'mert@brokerlink.com'
ORDER BY d.created_at DESC, po.created_at DESC
LIMIT 1;

-- EŞLEŞME 2: Caner Duru'nun 2. talebi → Ahmet Yılmaz'ın 1. portföyü
INSERT INTO matches (demand_id, portfolio_id, score, status, created_at)
SELECT 
    d.id as demand_id,
    po.id as portfolio_id,
    86 as score,
    'pending' as status,
    NOW() as created_at
FROM demands d
CROSS JOIN portfolios po
JOIN profiles dp ON d.user_id = dp.id
JOIN profiles pp ON po.user_id = pp.id
WHERE dp.email = 'test@brokerlink.com'
  AND pp.email = 'can@brokerlink.com'
ORDER BY d.created_at DESC, po.created_at DESC
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
  AND dp.email = 'test@brokerlink.com'
ORDER BY m.created_at DESC
LIMIT 5;
