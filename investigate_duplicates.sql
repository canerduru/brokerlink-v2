-- ============================================
-- DUPLICATE APPROVED MATCHES ARAŞTIRMASI
-- ============================================
-- Kullanıcı "Onaylanan" tab'ında 3 aynı kayıt görüyor:
-- "Boğaz Manzaralı Daire ↔ Suadiye Kiralık Daire" (Ahmet Yılmaz)
-- Bu kayıtlar Match ID: 5, 8, 10

-- ADIM 1: Bu 3 match'i detaylı incele
SELECT 
    '=== DUPLICATE APPROVED MATCHES ===' as info,
    m.id as match_id,
    m.status,
    m.score,
    m.created_at,
    
    -- Demand (Caner Duru'nun talebi)
    d.id as demand_id,
    d.title as demand_title,
    d.user_id as demand_owner_id,
    dp.name as demand_owner_name,
    
    -- Portfolio (Ahmet Yılmaz'ın portföyü)
    p.id as portfolio_id,
    p.title as portfolio_title,
    p.price as portfolio_price,
    p.user_id as portfolio_owner_id,
    pp.name as portfolio_owner_name
    
FROM matches m
LEFT JOIN demands d ON d.id = m.demand_id
LEFT JOIN profiles dp ON dp.id = d.user_id
LEFT JOIN portfolios p ON p.id = m.portfolio_id
LEFT JOIN profiles pp ON pp.id = p.user_id
WHERE m.id IN (5, 8, 10)
ORDER BY m.id;

-- ADIM 2: Tüm "Suadiye Kiralık Daire" taleplerini bul
SELECT 
    '=== TÜM SUADIYE TALEPLERİ ===' as info,
    id as demand_id,
    title,
    user_id,
    created_at
FROM demands
WHERE title ILIKE '%suadiye%'
ORDER BY created_at DESC;

-- ADIM 3: Bu taleplerin eşleşmelerini kontrol et
SELECT 
    '=== SUADIYE TALEPLERİNİN EŞLEŞMELERİ ===' as info,
    m.id as match_id,
    m.demand_id,
    d.title as demand_title,
    m.portfolio_id,
    p.title as portfolio_title,
    m.status,
    m.created_at
FROM matches m
LEFT JOIN demands d ON d.id = m.demand_id
LEFT JOIN portfolios p ON p.id = m.portfolio_id
WHERE m.demand_id IN (
    SELECT id FROM demands WHERE title ILIKE '%suadiye%'
)
ORDER BY m.demand_id, m.created_at DESC;

-- ADIM 4: Aynı demand_id + portfolio_id çiftini kontrol et
SELECT 
    '=== AYNI ÇİFTLER (DUPLICATE) ===' as info,
    demand_id,
    portfolio_id,
    COUNT(*) as duplicate_count,
    array_agg(id ORDER BY created_at DESC) as match_ids,
    array_agg(status ORDER BY created_at DESC) as statuses
FROM matches
WHERE demand_id IN (
    SELECT id FROM demands WHERE title ILIKE '%suadiye%'
)
GROUP BY demand_id, portfolio_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;
