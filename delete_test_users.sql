-- FAKE KULLANICILARI VE VERİLERİNİ SİL
-- Gerçek kullanıcılar: Caner Duru (test@brokerlink.com) ve c d (caner@brokerlink.com)
-- Silinecekler: Final Test, Mert Yılmaz, Ahmet Yılmaz

-- ============================================
-- ADIM 1: SİLİNECEKLERİ KONTROL ET
-- ============================================

-- Silinecek kullanıcılar
SELECT 
    id,
    name,
    email,
    'SILINECEK' as action
FROM profiles
WHERE email IN (
    'test_final@example.com',
    'mert@brokerlink.com',
    'cand@brokerlink.com'
);

-- Silinecek kullanıcıların portföyleri
SELECT 
    po.id,
    po.title,
    p.name as owner,
    'SILINECEK PORTFÖY' as action
FROM portfolios po
JOIN profiles p ON po.user_id = p.id
WHERE p.email IN (
    'test_final@example.com',
    'mert@brokerlink.com',
    'cand@brokerlink.com'
);

-- Silinecek kullanıcıların talepleri
SELECT 
    d.id,
    d.title,
    p.name as owner,
    'SILINECEK TALEP' as action
FROM demands d
JOIN profiles p ON d.user_id = p.id
WHERE p.email IN (
    'test_final@example.com',
    'mert@brokerlink.com',
    'cand@brokerlink.com'
);

-- ============================================
-- ADIM 2: SİLME İŞLEMLERİ
-- ============================================
-- Yukarıdaki kontrolleri yaptıktan sonra bu yorumları kaldır:

/*
-- 1. Fake kullanıcıların portföylerini sil
DELETE FROM portfolios
WHERE user_id IN (
    SELECT id FROM profiles
    WHERE email IN (
        'test_final@example.com',
        'mert@brokerlink.com',
        'cand@brokerlink.com'
    )
);

-- 2. Fake kullanıcıların taleplerini sil
DELETE FROM demands
WHERE user_id IN (
    SELECT id FROM profiles
    WHERE email IN (
        'test_final@example.com',
        'mert@brokerlink.com',
        'cand@brokerlink.com'
    )
);

-- 3. Fake kullanıcıları sil
DELETE FROM profiles
WHERE email IN (
    'test_final@example.com',
    'mert@brokerlink.com',
    'cand@brokerlink.com'
);
*/

-- ============================================
-- ADIM 3: SİLME SONRASI KONTROL
-- ============================================

/*
-- Kalan kullanıcılar (sadece Caner Duru ve c d olmalı)
SELECT 
    name,
    email,
    company,
    'KALAN KULLANICI' as status
FROM profiles
ORDER BY created_at;

-- Kalan portföyler (sadece Caner Duru'nun 69 portföyü)
SELECT COUNT(*) as remaining_portfolios FROM portfolios;

-- Kalan talepler (Caner Duru 45 + c d 1 = 46)
SELECT COUNT(*) as remaining_demands FROM demands;

-- Kalan eşleşmeler
SELECT COUNT(*) as remaining_matches FROM matches;

-- Detaylı özet
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
