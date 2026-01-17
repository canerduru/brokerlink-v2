-- TEMİZ VE BASİT: Konya Arsa Eşleşmesi Oluştur
-- Supabase SQL Editor'da çalıştır

-- ADIM 1: Senin için yeni talep oluştur
INSERT INTO demands (
    user_id,
    title,
    category,
    type,
    budget,
    max_budget,
    district,
    rooms,
    status,
    created_at
)
VALUES (
    (SELECT id FROM auth.users ORDER BY last_sign_in_at DESC LIMIT 1), -- Senin user_id'n
    'Konya''da Arsa Arıyorum',
    'Arsa',
    'Satılık',
    10000000,
    20000000,
    'Selçuklu, Konya',
    '-',
    'active',
    NOW()
)
RETURNING id, title, budget, max_budget, district;

-- ADIM 2: Mert Yılmaz'ın bir Arsa portföyü var mı kontrol et
SELECT 
    p.id,
    p.title,
    p.category,
    p.price,
    p.district,
    pr.name as owner_name
FROM portfolios p
JOIN profiles pr ON p.user_id = pr.id
WHERE pr.name ILIKE '%mert%'
  AND p.category = 'Arsa'
LIMIT 3;

-- EĞER MERT YILMAZ'IN ARSA PORTFÖYÜ YOKSA, ÖNCE BİR TANE OLUŞTUR:
INSERT INTO portfolios (
    user_id,
    title,
    category,
    type,
    price,
    district,
    rooms,
    area,
    image_url,
    created_at
)
VALUES (
    (SELECT id FROM profiles WHERE name ILIKE '%mert%yilmaz%' LIMIT 1), -- Mert Yılmaz'ın ID'si
    'Selçuklu Merkez İmarlı Arsa',
    'Arsa',
    'Satılık',
    15000000,
    'Selçuklu, Konya',
    '-',
    '500m²',
    'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=800&q=80',
    NOW()
)
RETURNING id, title, price, district;

-- ADIM 3: Eşleşme oluştur (Senin yeni talebin + Mert'in arsa portföyü)
INSERT INTO matches (demand_id, portfolio_id, score, status, created_at)
VALUES (
    (SELECT id FROM demands WHERE title = 'Konya''da Arsa Arıyorum' ORDER BY created_at DESC LIMIT 1),
    (SELECT id FROM portfolios WHERE title = 'Selçuklu Merkez İmarlı Arsa' ORDER BY created_at DESC LIMIT 1),
    92,
    'pending',
    NOW()
)
RETURNING id, demand_id, portfolio_id, score, status;

-- ADIM 4: Sonucu kontrol et
SELECT 
    m.id as match_id,
    m.score,
    m.status,
    d.title as demand_title,
    d.budget as demand_budget,
    d.max_budget as demand_max_budget,
    d.district as demand_district,
    (SELECT name FROM profiles WHERE id = d.user_id) as demand_owner,
    p.title as portfolio_title,
    p.price as portfolio_price,
    p.district as portfolio_district,
    (SELECT name FROM profiles WHERE id = p.user_id) as portfolio_owner
FROM matches m
JOIN demands d ON m.demand_id = d.id
JOIN portfolios p ON m.portfolio_id = p.id
WHERE d.title = 'Konya''da Arsa Arıyorum'
ORDER BY m.created_at DESC
LIMIT 1;
