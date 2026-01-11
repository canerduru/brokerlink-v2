-- ============================================
-- VERİ DOĞRULAMA: Eşleşmelerdeki Broker Bilgileri
-- ============================================
-- Caner Duru'nun user_id'sini bulup, hangi portföy/taleplerin
-- ona ait olduğunu kontrol edeceğiz.

-- ADIM 1: Caner Duru'nun user_id'sini bul
SELECT 
    '=== CANER DURU KULLANICI BİLGİSİ ===' as info,
    id as user_id,
    name,
    email,
    company,
    title
FROM profiles
WHERE name ILIKE '%caner%' OR name ILIKE '%duru%';

-- ADIM 2: Tüm kullanıcıları listele (karşılaştırma için)
SELECT 
    '=== TÜM KULLANICILAR ===' as info,
    id as user_id,
    name,
    email
FROM profiles
ORDER BY created_at DESC
LIMIT 10;

-- ADIM 3: Portfolios - Kime ait?
SELECT 
    '=== PORTFÖYLER VE SAHİPLERİ ===' as info,
    p.id as portfolio_id,
    p.title as portfolio_title,
    p.user_id,
    pr.name as owner_name,
    pr.email as owner_email
FROM portfolios p
LEFT JOIN profiles pr ON pr.id = p.user_id
ORDER BY p.created_at DESC;

-- ADIM 4: Demands - Kime ait?
SELECT 
    '=== TALEPLER VE SAHİPLERİ ===' as info,
    d.id as demand_id,
    d.title as demand_title,
    d.user_id,
    pr.name as owner_name,
    pr.email as owner_email
FROM demands d
LEFT JOIN profiles pr ON pr.id = d.user_id
ORDER BY d.created_at DESC;

-- ADIM 5: Matches - Detaylı Analiz
SELECT 
    '=== EŞLEŞMELER DETAYLI ===' as info,
    m.id as match_id,
    m.status,
    m.score,
    
    -- Demand bilgisi
    d.id as demand_id,
    d.title as demand_title,
    d.user_id as demand_owner_id,
    dp.name as demand_owner_name,
    
    -- Portfolio bilgisi
    p.id as portfolio_id,
    p.title as portfolio_title,
    p.user_id as portfolio_owner_id,
    pp.name as portfolio_owner_name
    
FROM matches m
LEFT JOIN demands d ON d.id = m.demand_id
LEFT JOIN profiles dp ON dp.id = d.user_id
LEFT JOIN portfolios p ON p.id = m.portfolio_id
LEFT JOIN profiles pp ON pp.id = p.user_id
ORDER BY m.created_at DESC;

-- ============================================
-- Bu sorguları çalıştırın ve sonuçları gönderin.
-- Özellikle son sorgu (ADIM 5) çok önemli!
-- ============================================
