-- KONYA ARSA EŞLEŞMESİ - Mert Yılmaz ID'si ile
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

-- ADIM 2: Mert Yılmaz için Arsa portföyü oluştur
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
    '4c0e0bda-4d06-464c-9bb5-58594608d619', -- Mert Yılmaz'ın ID'si (sabit)
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

-- ADIM 3: Eşleşme oluştur (Senin talebin + Mert'in portföyü)
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
    d.title as my_demand,
    d.budget || ' - ' || d.max_budget as my_budget,
    d.district as my_location,
    p.title as mert_portfolio,
    p.price as mert_price,
    p.district as mert_location,
    (SELECT name FROM profiles WHERE id = p.user_id) as portfolio_owner
FROM matches m
JOIN demands d ON m.demand_id = d.id
JOIN portfolios p ON m.portfolio_id = p.id
WHERE d.title = 'Konya''da Arsa Arıyorum'
ORDER BY m.created_at DESC
LIMIT 1;
