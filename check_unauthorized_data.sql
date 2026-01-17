-- BU 5 KULLANICI DIŞINDA PORTFÖY/TALEP VAR MI KONTROL ET

-- Tanımlı kullanıcılar (tutulacaklar)
-- 1. Caner Duru - test@brokerlink.com
-- 2. c d - caner@brokerlink.com
-- 3. Mert Yılmaz - mert@brokerlink.com
-- 4. Ahmet Yılmaz - can@brokerlink.com
-- 5. Final Test - test_final@example.com

-- ============================================
-- ADIM 1: BU 5 KULLANICI DIŞINDA KULLANICI VAR MI?
-- ============================================

SELECT 
    id,
    name,
    email,
    'TANIMLI OLMAYAN KULLANICI - SİLİNECEK' as action
FROM profiles
WHERE email NOT IN (
    'test@brokerlink.com',
    'caner@brokerlink.com',
    'mert@brokerlink.com',
    'can@brokerlink.com',
    'test_final@example.com'
);

-- ============================================
-- ADIM 2: BU 5 KULLANICI DIŞINDA PORTFÖY VAR MI?
-- ============================================

SELECT 
    po.id,
    po.title,
    p.name as owner,
    p.email,
    'SİLİNECEK PORTFÖY' as action
FROM portfolios po
JOIN profiles p ON po.user_id = p.id
WHERE p.email NOT IN (
    'test@brokerlink.com',
    'caner@brokerlink.com',
    'mert@brokerlink.com',
    'can@brokerlink.com',
    'test_final@example.com'
);

-- ============================================
-- ADIM 3: BU 5 KULLANICI DIŞINDA TALEP VAR MI?
-- ============================================

SELECT 
    d.id,
    d.title,
    p.name as owner,
    p.email,
    'SİLİNECEK TALEP' as action
FROM demands d
JOIN profiles p ON d.user_id = p.id
WHERE p.email NOT IN (
    'test@brokerlink.com',
    'caner@brokerlink.com',
    'mert@brokerlink.com',
    'can@brokerlink.com',
    'test_final@example.com'
);

-- ============================================
-- ADIM 4: SAYILARI KONTROL ET
-- ============================================

-- Tanımlı olmayan kullanıcı sayısı
SELECT COUNT(*) as unauthorized_user_count
FROM profiles
WHERE email NOT IN (
    'test@brokerlink.com',
    'caner@brokerlink.com',
    'mert@brokerlink.com',
    'can@brokerlink.com',
    'test_final@example.com'
);

-- Tanımlı olmayan portföy sayısı
SELECT COUNT(*) as unauthorized_portfolio_count
FROM portfolios po
JOIN profiles p ON po.user_id = p.id
WHERE p.email NOT IN (
    'test@brokerlink.com',
    'caner@brokerlink.com',
    'mert@brokerlink.com',
    'can@brokerlink.com',
    'test_final@example.com'
);

-- Tanımlı olmayan talep sayısı
SELECT COUNT(*) as unauthorized_demand_count
FROM demands d
JOIN profiles p ON d.user_id = p.id
WHERE p.email NOT IN (
    'test@brokerlink.com',
    'caner@brokerlink.com',
    'mert@brokerlink.com',
    'can@brokerlink.com',
    'test_final@example.com'
);
