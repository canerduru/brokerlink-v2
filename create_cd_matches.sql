-- C D KULLANICISI İLE EŞLEŞMELER OLUŞTUR
-- Caner Duru'nun portföy ve talepleriyle c d arasında 2'şer eşleşme

-- ============================================
-- ADIM 1: KULLANICI ID'LERİNİ BUL
-- ============================================

-- Caner Duru ID'si
SELECT id, name, email FROM profiles WHERE email = 'test@brokerlink.com';

-- c d ID'si
SELECT id, name, email FROM profiles WHERE email = 'caner@brokerlink.com';

-- ============================================
-- ADIM 2: CANER DURU'NUN PORTFÖY VE TALEPLERİNİ LİSTELE
-- ============================================

-- Caner Duru'nun portföyleri (ilk 5 tanesini göster)
SELECT 
    id,
    title,
    price,
    category,
    district
FROM portfolios
WHERE user_id = (SELECT id FROM profiles WHERE email = 'test@brokerlink.com')
ORDER BY created_at DESC
LIMIT 5;

-- Caner Duru'nun talepleri (ilk 5 tanesini göster)
SELECT 
    id,
    title,
    budget,
    max_budget,
    category,
    district
FROM demands
WHERE user_id = (SELECT id FROM profiles WHERE email = 'test@brokerlink.com')
ORDER BY created_at DESC
LIMIT 5;

-- c d'nin talebi
SELECT 
    id,
    title,
    budget,
    max_budget,
    category,
    district
FROM demands
WHERE user_id = (SELECT id FROM profiles WHERE email = 'caner@brokerlink.com')
ORDER BY created_at DESC;

-- ============================================
-- ADIM 3: EŞLEŞMELERİ OLUŞTUR
-- ============================================
-- Yukarıdaki sorguları çalıştır, ID'leri not et, sonra aşağıdaki yorumları kaldır

/*
-- EŞLEŞME 1: c d'nin talebi → Caner Duru'nun portföyü
INSERT INTO matches (
    demand_id,
    portfolio_id,
    score,
    status,
    created_at
) VALUES (
    (SELECT id FROM demands WHERE user_id = (SELECT id FROM profiles WHERE email = 'caner@brokerlink.com') LIMIT 1),
    (SELECT id FROM portfolios WHERE user_id = (SELECT id FROM profiles WHERE email = 'test@brokerlink.com') ORDER BY created_at DESC LIMIT 1 OFFSET 0),
    85,
    'pending',
    NOW()
);

-- EŞLEŞME 2: c d'nin talebi → Caner Duru'nun başka portföyü
INSERT INTO matches (
    demand_id,
    portfolio_id,
    score,
    status,
    created_at
) VALUES (
    (SELECT id FROM demands WHERE user_id = (SELECT id FROM profiles WHERE email = 'caner@brokerlink.com') LIMIT 1),
    (SELECT id FROM portfolios WHERE user_id = (SELECT id FROM profiles WHERE email = 'test@brokerlink.com') ORDER BY created_at DESC LIMIT 1 OFFSET 1),
    82,
    'pending',
    NOW()
);

-- EŞLEŞME 3: Caner Duru'nun talebi → c d'nin portföyü (eğer c d'nin portföyü varsa)
-- NOT: c d'nin portföyü yok, bu yüzden bu eşleşme yapılamaz
-- Bunun yerine Caner Duru'nun talebi → Mert Yılmaz'ın portföyü yapabiliriz

-- EŞLEŞME 3: Caner Duru'nun talebi → Mert Yılmaz'ın portföyü
INSERT INTO matches (
    demand_id,
    portfolio_id,
    score,
    status,
    created_at
) VALUES (
    (SELECT id FROM demands WHERE user_id = (SELECT id FROM profiles WHERE email = 'test@brokerlink.com') ORDER BY created_at DESC LIMIT 1 OFFSET 0),
    (SELECT id FROM portfolios WHERE user_id = (SELECT id FROM profiles WHERE email = 'mert@brokerlink.com') LIMIT 1 OFFSET 0),
    88,
    'pending',
    NOW()
);

-- EŞLEŞME 4: Caner Duru'nun başka talebi → Mert Yılmaz'ın başka portföyü
INSERT INTO matches (
    demand_id,
    portfolio_id,
    score,
    status,
    created_at
) VALUES (
    (SELECT id FROM demands WHERE user_id = (SELECT id FROM profiles WHERE email = 'test@brokerlink.com') ORDER BY created_at DESC LIMIT 1 OFFSET 1),
    (SELECT id FROM portfolios WHERE user_id = (SELECT id FROM profiles WHERE email = 'mert@brokerlink.com') LIMIT 1 OFFSET 1),
    90,
    'pending',
    NOW()
);
*/

-- ============================================
-- ADIM 4: OLUŞTURULAN EŞLEŞMELERİ KONTROL ET
-- ============================================

/*
-- Son eklenen eşleşmeler
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
ORDER BY m.created_at DESC
LIMIT 10;

-- Toplam eşleşme sayısı
SELECT COUNT(*) as total_matches FROM matches WHERE status = 'pending';
*/
