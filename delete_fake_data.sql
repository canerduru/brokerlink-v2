-- FAKE VERİLERİ SİL
-- ÖNCELİKLE identify_fake_data.sql'i çalıştır ve kontrol et!

-- ============================================
-- ADIM 1: ÖNCE KONTROL ET
-- ============================================

-- Silinecek portföyleri göster
SELECT 
    po.id,
    po.title,
    p.name as owner,
    'SILINECEK PORTFÖY' as action
FROM portfolios po
JOIN profiles p ON po.user_id = p.id
WHERE p.name LIKE '%Mert%' 
   OR p.name LIKE '%Test%'
   OR p.email LIKE '%test%';

-- Silinecek talepleri göster
SELECT 
    d.id,
    d.title,
    p.name as owner,
    'SILINECEK TALEP' as action
FROM demands d
JOIN profiles p ON d.user_id = p.id
WHERE p.name LIKE '%Mert%' 
   OR p.name LIKE '%Test%'
   OR p.email LIKE '%test%';

-- ============================================
-- ADIM 2: SİLME İŞLEMLERİ (Yorum satırlarını kaldır)
-- ============================================

/*
-- FAKE PORTFÖYLERI SİL
DELETE FROM portfolios
WHERE user_id IN (
    SELECT id FROM profiles
    WHERE name LIKE '%Mert%' 
       OR name LIKE '%Test%'
       OR email LIKE '%test%'
);

-- FAKE TALEPLERİ SİL
DELETE FROM demands
WHERE user_id IN (
    SELECT id FROM profiles
    WHERE name LIKE '%Mert%' 
       OR name LIKE '%Test%'
       OR email LIKE '%test%'
);

-- FAKE KULLANICILARI SİL (opsiyonel - sadece tamamen silmek istersen)
-- DİKKAT: Bu işlem geri alınamaz!
DELETE FROM profiles
WHERE name LIKE '%Mert%' 
   OR name LIKE '%Test%'
   OR email LIKE '%test%';
*/

-- ============================================
-- ADIM 3: SİLME SONRASI KONTROL
-- ============================================

/*
-- Kalan portföy sayısı
SELECT COUNT(*) as remaining_portfolios FROM portfolios;

-- Kalan talep sayısı
SELECT COUNT(*) as remaining_demands FROM demands;

-- Kalan eşleşme sayısı
SELECT COUNT(*) as remaining_matches FROM matches;

-- Kalan kullanıcı sayısı
SELECT COUNT(*) as remaining_users FROM profiles;

-- Detaylı özet
SELECT 
    'Portfolios' as table_name,
    COUNT(*) as count
FROM portfolios
UNION ALL
SELECT 
    'Demands' as table_name,
    COUNT(*) as count
FROM demands
UNION ALL
SELECT 
    'Matches' as table_name,
    COUNT(*) as count
FROM matches
UNION ALL
SELECT 
    'Users' as table_name,
    COUNT(*) as count
FROM profiles;
*/

-- ============================================
-- ADIM 4: GERÇEK VERİLERİ GÖSTER
-- ============================================

/*
-- Kalan gerçek portföyler
SELECT 
    po.title,
    po.price,
    p.name as owner
FROM portfolios po
JOIN profiles p ON po.user_id = p.id
ORDER BY po.created_at DESC;

-- Kalan gerçek talepler
SELECT 
    d.title,
    d.budget,
    d.max_budget,
    p.name as owner
FROM demands d
JOIN profiles p ON d.user_id = p.id
ORDER BY d.created_at DESC;
*/
