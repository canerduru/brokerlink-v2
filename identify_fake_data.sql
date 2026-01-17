-- FAKE PORTFÖY VE TALEP TEMİZLEME
-- Pazara çıkmadan önce test verilerini temizle

-- ============================================
-- ADIM 1: KULLANICILARI İNCELE
-- ============================================

-- Tüm kullanıcıları listele
SELECT 
    id,
    name,
    email,
    company,
    created_at,
    CASE 
        WHEN name LIKE '%Mert%' THEN 'FAKE - TEST USER'
        WHEN name LIKE '%Test%' THEN 'FAKE - TEST USER'
        WHEN email LIKE '%test%' THEN 'FAKE - TEST USER'
        ELSE 'REAL USER'
    END as user_type
FROM profiles
ORDER BY created_at;

-- ============================================
-- ADIM 2: PORTFÖY DAĞILIMINI İNCELE
-- ============================================

-- Kullanıcı başına portföy sayısı
SELECT 
    p.name as owner,
    p.email,
    COUNT(po.id) as portfolio_count,
    CASE 
        WHEN p.name LIKE '%Mert%' THEN 'FAKE'
        WHEN p.name LIKE '%Test%' THEN 'FAKE'
        ELSE 'REAL'
    END as user_type
FROM profiles p
LEFT JOIN portfolios po ON p.id = po.user_id
GROUP BY p.id, p.name, p.email
HAVING COUNT(po.id) > 0
ORDER BY portfolio_count DESC;

-- ============================================
-- ADIM 3: TALEP DAĞILIMINI İNCELE
-- ============================================

-- Kullanıcı başına talep sayısı
SELECT 
    p.name as owner,
    p.email,
    COUNT(d.id) as demand_count,
    CASE 
        WHEN p.name LIKE '%Mert%' THEN 'FAKE'
        WHEN p.name LIKE '%Test%' THEN 'FAKE'
        ELSE 'REAL'
    END as user_type
FROM profiles p
LEFT JOIN demands d ON p.id = d.user_id
GROUP BY p.id, p.name, p.email
HAVING COUNT(d.id) > 0
ORDER BY demand_count DESC;

-- ============================================
-- ADIM 4: FAKE PORTFÖYLERI LİSTELE
-- ============================================

SELECT 
    po.id,
    po.title,
    po.price,
    p.name as owner,
    po.created_at,
    'SILINECEK' as action
FROM portfolios po
JOIN profiles p ON po.user_id = p.id
WHERE p.name LIKE '%Mert%' 
   OR p.name LIKE '%Test%'
   OR p.email LIKE '%test%'
ORDER BY po.created_at DESC;

-- ============================================
-- ADIM 5: FAKE TALEPLERİ LİSTELE
-- ============================================

SELECT 
    d.id,
    d.title,
    d.budget,
    d.max_budget,
    p.name as owner,
    d.created_at,
    'SILINECEK' as action
FROM demands d
JOIN profiles p ON d.user_id = p.id
WHERE p.name LIKE '%Mert%' 
   OR p.name LIKE '%Test%'
   OR p.email LIKE '%test%'
ORDER BY d.created_at DESC;

-- ============================================
-- ADIM 6: SAYILARI KONTROL ET
-- ============================================

-- Fake portföy sayısı
SELECT COUNT(*) as fake_portfolio_count
FROM portfolios po
JOIN profiles p ON po.user_id = p.id
WHERE p.name LIKE '%Mert%' 
   OR p.name LIKE '%Test%'
   OR p.email LIKE '%test%';

-- Fake talep sayısı
SELECT COUNT(*) as fake_demand_count
FROM demands d
JOIN profiles p ON d.user_id = p.id
WHERE p.name LIKE '%Mert%' 
   OR p.name LIKE '%Test%'
   OR p.email LIKE '%test%';

-- Gerçek portföy sayısı (kalacak)
SELECT COUNT(*) as real_portfolio_count
FROM portfolios po
JOIN profiles p ON po.user_id = p.id
WHERE p.name NOT LIKE '%Mert%' 
  AND p.name NOT LIKE '%Test%'
  AND p.email NOT LIKE '%test%';

-- Gerçek talep sayısı (kalacak)
SELECT COUNT(*) as real_demand_count
FROM demands d
JOIN profiles p ON d.user_id = p.id
WHERE p.name NOT LIKE '%Mert%' 
  AND p.name NOT LIKE '%Test%'
  AND p.email NOT LIKE '%test%';

-- ============================================
-- ADIM 7: GERÇEK VERİLERİ GÖSTER (KALACAKLAR)
-- ============================================

-- Gerçek portföyler
SELECT 
    po.id,
    po.title,
    po.price,
    p.name as owner,
    po.created_at,
    'KALACAK' as action
FROM portfolios po
JOIN profiles p ON po.user_id = p.id
WHERE p.name NOT LIKE '%Mert%' 
  AND p.name NOT LIKE '%Test%'
  AND p.email NOT LIKE '%test%'
ORDER BY po.created_at DESC;

-- Gerçek talepler
SELECT 
    d.id,
    d.title,
    d.budget,
    d.max_budget,
    p.name as owner,
    d.created_at,
    'KALACAK' as action
FROM demands d
JOIN profiles p ON d.user_id = p.id
WHERE p.name NOT LIKE '%Mert%' 
  AND p.name NOT LIKE '%Test%'
  AND p.email NOT LIKE '%test%'
ORDER BY d.created_at DESC;

-- ============================================
-- ÖNEMLİ NOT:
-- ============================================
-- Yukarıdaki sorguları çalıştır ve sonuçları kontrol et!
-- Eğer her şey doğruysa, delete_fake_data.sql dosyasını kullan
