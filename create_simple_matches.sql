-- YENİ EŞLEŞMELERİ OLUŞTUR
-- c d'nin talebi ile Caner Duru'nun portföyleri arasında 2 yeni eşleşme

-- ADIM 1: c d'nin talep ID'sini bul
SELECT 
    d.id as demand_id,
    d.title,
    p.name as owner
FROM demands d
JOIN profiles p ON d.user_id = p.id
WHERE p.email = 'caner@brokerlink.com';

-- ADIM 2: Caner Duru'nun portföy ID'lerini bul (ilk 2 tane)
SELECT 
    po.id as portfolio_id,
    po.title,
    po.price,
    p.name as owner
FROM portfolios po
JOIN profiles p ON po.user_id = p.id
WHERE p.email = 'test@brokerlink.com'
ORDER BY po.created_at DESC
LIMIT 2;

-- ADIM 3: Yukarıdaki sonuçları not et ve aşağıdaki INSERT'leri çalıştır
-- (ID'leri yukarıdaki sonuçlarla değiştir)

-- Örnek: Eğer c d'nin talep ID'si 63 ve senin portföy ID'lerin 101, 102 ise:

/*
INSERT INTO matches (demand_id, portfolio_id, score, status, created_at)
VALUES (63, 101, 87, 'pending', NOW());

INSERT INTO matches (demand_id, portfolio_id, score, status, created_at)
VALUES (63, 102, 84, 'pending', NOW());
*/

-- ADIM 4: Kontrol et
/*
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
ORDER BY m.created_at DESC
LIMIT 10;
*/
