-- YENİ PORTFÖY EŞLEŞMESİ: Mert Yılmaz'ın Talebi + Senin Portföyün
-- Supabase SQL Editor'da çalıştır

-- ADIM 1: Mert Yılmaz için yeni bir talep oluştur
INSERT INTO demands (
    user_id,
    title,
    category,
    type,
    budget,
    max_budget,
    district,
    location,
    city,
    rooms,
    status,
    created_at
)
VALUES (
    '4c0e0bda-4d06-464c-9bb5-58594608d619', -- Mert Yılmaz'ın ID'si
    'Kadıköy''de Deniz Manzaralı Daire',
    'Daire',
    'Satılık',
    35000000,
    50000000,
    'Fenerbahçe',
    'Kadıköy',
    'İstanbul',
    '3+1',
    'active',
    NOW()
)
RETURNING id, title, budget, max_budget, district;

-- ADIM 2: Senin portföylerini listele (Daire kategorisinde)
SELECT 
    p.id,
    p.title,
    p.category,
    p.type,
    p.price,
    p.district,
    p.location,
    p.city,
    p.rooms
FROM portfolios p
WHERE p.user_id = (SELECT id FROM auth.users ORDER BY last_sign_in_at DESC LIMIT 1)
  AND p.category = 'Daire'
  AND p.type = 'Satılık'
ORDER BY p.created_at DESC
LIMIT 5;

-- ADIM 3: Eşleşme oluştur (Mert'in talebi + Senin portföyün)
INSERT INTO matches (demand_id, portfolio_id, score, status, created_at)
VALUES (
    (SELECT id FROM demands WHERE title = 'Kadıköy''de Deniz Manzaralı Daire' ORDER BY created_at DESC LIMIT 1),
    (SELECT id FROM portfolios 
     WHERE user_id = (SELECT id FROM auth.users ORDER BY last_sign_in_at DESC LIMIT 1)
       AND category = 'Daire'
       AND type = 'Satılık'
     ORDER BY created_at DESC 
     LIMIT 1),
    91,
    'pending',
    NOW()
)
RETURNING id, demand_id, portfolio_id, score, status;

-- ADIM 4: Sonucu kontrol et
SELECT 
    m.id as match_id,
    m.score,
    m.status,
    d.title as mert_demand,
    d.budget || ' - ' || d.max_budget as mert_budget,
    d.district || ', ' || d.location as mert_location,
    (SELECT name FROM profiles WHERE id = d.user_id) as demand_owner,
    p.title as my_portfolio,
    p.price as my_price,
    p.district || ', ' || p.location as my_location,
    (SELECT name FROM profiles WHERE id = p.user_id) as portfolio_owner
FROM matches m
JOIN demands d ON m.demand_id = d.id
JOIN portfolios p ON m.portfolio_id = p.id
WHERE d.title = 'Kadıköy''de Deniz Manzaralı Daire'
ORDER BY m.created_at DESC
LIMIT 1;
