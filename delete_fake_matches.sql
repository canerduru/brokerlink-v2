-- HIZLI TEMİZLEME: Fake eşleşmeleri sil

-- ÖNCELİKLE KONTROL ET: Hangi eşleşmeler silinecek?
SELECT 
    m.id,
    m.status,
    d.title as demand_title,
    dp.name as demand_owner,
    p.title as portfolio_title,
    pp.name as portfolio_owner,
    'SILINECEK' as action
FROM matches m
LEFT JOIN demands d ON m.demand_id = d.id
LEFT JOIN profiles dp ON d.user_id = dp.id
LEFT JOIN portfolios p ON m.portfolio_id = p.id
LEFT JOIN profiles pp ON p.user_id = pp.id
WHERE dp.name LIKE '%Mert%' 
   OR pp.name LIKE '%Mert%';

-- Yukarıdaki sorguyu çalıştır ve kontrol et!
-- Eğer doğruysa, aşağıdaki DELETE komutunu çalıştır:

/*
-- FAKE EŞLEŞMELERİ SİL (Mert Yılmaz ile olanlar)
DELETE FROM matches
WHERE id IN (
    SELECT m.id
    FROM matches m
    LEFT JOIN demands d ON m.demand_id = d.id
    LEFT JOIN profiles dp ON d.user_id = dp.id
    LEFT JOIN portfolios p ON m.portfolio_id = p.id
    LEFT JOIN profiles pp ON p.user_id = pp.id
    WHERE dp.name LIKE '%Mert%' 
       OR pp.name LIKE '%Mert%'
);

-- Silme sonrası kontrol
SELECT COUNT(*) as remaining_matches FROM matches;
*/
