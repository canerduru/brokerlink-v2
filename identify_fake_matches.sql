-- FAKE MATCH TEMİZLEME PLANI
-- 40 eşleşme çok fazla - bunların çoğu test amaçlı oluşturulmuş

-- ADIM 1: Tüm eşleşmeleri detaylı incele
SELECT 
    m.id,
    m.status,
    m.score,
    TO_CHAR(m.created_at, 'YYYY-MM-DD HH24:MI') as created,
    d.title as demand_title,
    dp.name as demand_owner,
    p.title as portfolio_title,
    pp.name as portfolio_owner
FROM matches m
LEFT JOIN demands d ON m.demand_id = d.id
LEFT JOIN profiles dp ON d.user_id = dp.id
LEFT JOIN portfolios p ON m.portfolio_id = p.id
LEFT JOIN profiles pp ON p.user_id = pp.id
ORDER BY m.created_at DESC;

-- ADIM 2: Kullanıcı başına eşleşme dağılımı
SELECT 
    COALESCE(pp.name, 'Unknown') as portfolio_owner,
    COUNT(*) as match_count,
    STRING_AGG(DISTINCT dp.name, ', ') as matched_with
FROM matches m
LEFT JOIN demands d ON m.demand_id = d.id
LEFT JOIN profiles dp ON d.user_id = dp.id
LEFT JOIN portfolios p ON m.portfolio_id = p.id
LEFT JOIN profiles pp ON p.user_id = pp.id
GROUP BY pp.name
ORDER BY match_count DESC;

-- ADIM 3: Gerçek kullanıcıyı bul (current user)
SELECT id, name, email FROM profiles 
WHERE email NOT LIKE '%test%' 
  AND email NOT LIKE '%mert%'
ORDER BY created_at 
LIMIT 5;

-- ADIM 4: Test kullanıcılarını tespit et
SELECT DISTINCT
    p.id,
    p.name,
    p.email,
    p.created_at
FROM profiles p
WHERE p.name LIKE '%Mert%' 
   OR p.name LIKE '%Test%'
   OR p.email LIKE '%test%';

-- ADIM 5: Fake eşleşmeleri say
-- (Mert Yılmaz veya test kullanıcılarıyla olan tüm eşleşmeler)
SELECT COUNT(*) as fake_match_count
FROM matches m
LEFT JOIN demands d ON m.demand_id = d.id
LEFT JOIN profiles dp ON d.user_id = dp.id
LEFT JOIN portfolios p ON m.portfolio_id = p.id
LEFT JOIN profiles pp ON p.user_id = pp.id
WHERE dp.name LIKE '%Mert%' 
   OR pp.name LIKE '%Mert%'
   OR dp.name LIKE '%Test%'
   OR pp.name LIKE '%Test%';

-- ADIM 6: Gerçek eşleşmeleri say
-- (Sadece gerçek kullanıcılar arasındaki eşleşmeler)
SELECT COUNT(*) as real_match_count
FROM matches m
LEFT JOIN demands d ON m.demand_id = d.id
LEFT JOIN profiles dp ON d.user_id = dp.id
LEFT JOIN portfolios p ON m.portfolio_id = p.id
LEFT JOIN profiles pp ON p.user_id = pp.id
WHERE dp.name NOT LIKE '%Mert%' 
  AND pp.name NOT LIKE '%Mert%'
  AND dp.name NOT LIKE '%Test%'
  AND pp.name NOT LIKE '%Test%';

-- ÖNEMLİ: Silme işlemini yapmadan önce yukarıdaki sorguları çalıştır
-- ve hangi eşleşmelerin silineceğini onayla!
