-- BU 5 KULLANICI DIŞINDA VERİLERİ SİL
-- ÖNCE check_unauthorized_data.sql'i çalıştır ve kontrol et!

-- ============================================
-- SİLME İŞLEMLERİ (Yorum satırlarını kaldır)
-- ============================================

/*
-- 1. Tanımlı olmayan kullanıcıların portföylerini sil
DELETE FROM portfolios
WHERE user_id IN (
    SELECT id FROM profiles
    WHERE email NOT IN (
        'test@brokerlink.com',
        'caner@brokerlink.com',
        'mert@brokerlink.com',
        'can@brokerlink.com',
        'test_final@example.com'
    )
);

-- 2. Tanımlı olmayan kullanıcıların taleplerini sil
DELETE FROM demands
WHERE user_id IN (
    SELECT id FROM profiles
    WHERE email NOT IN (
        'test@brokerlink.com',
        'caner@brokerlink.com',
        'mert@brokerlink.com',
        'can@brokerlink.com',
        'test_final@example.com'
    )
);

-- 3. Tanımlı olmayan kullanıcıları sil
DELETE FROM profiles
WHERE email NOT IN (
    'test@brokerlink.com',
    'caner@brokerlink.com',
    'mert@brokerlink.com',
    'can@brokerlink.com',
    'test_final@example.com'
);
*/

-- ============================================
-- SİLME SONRASI KONTROL
-- ============================================

/*
-- Kalan kullanıcılar (sadece 5 olmalı)
SELECT 
    name,
    email,
    'KALAN KULLANICI' as status
FROM profiles
ORDER BY created_at;

-- Toplam sayılar
SELECT 
    'Users' as item,
    COUNT(*) as count
FROM profiles
UNION ALL
SELECT 
    'Portfolios' as item,
    COUNT(*) as count
FROM portfolios
UNION ALL
SELECT 
    'Demands' as item,
    COUNT(*) as count
FROM demands
UNION ALL
SELECT 
    'Matches' as item,
    COUNT(*) as count
FROM matches;
*/
