-- TERS YÖNLÜ EŞLEŞME: Senin Talebin + Mert Yılmaz'ın Portföyü
-- Supabase SQL Editor'da çalıştır

-- 1. Önce Mert Yılmaz'ı bul
SELECT 
    'Mert Yilmaz User' as info,
    u.id as user_id,
    u.email,
    p.name
FROM auth.users u
JOIN profiles p ON p.id = u.id
WHERE p.name ILIKE '%mert%yilmaz%'
LIMIT 1;

-- 2. Senin user_id'ni bul (en son giriş yapan)
SELECT 
    'Logged In User' as info,
    id as user_id,
    email,
    (SELECT name FROM profiles WHERE profiles.id = auth.users.id) as name
FROM auth.users 
ORDER BY last_sign_in_at DESC 
LIMIT 1;

-- 3. ÖNCE SENİN İÇİN BİR TALEP OLUŞTUR: "Konya'da Arsa Arıyorum"
WITH logged_in_user AS (
  SELECT id FROM auth.users ORDER BY last_sign_in_at DESC LIMIT 1
)
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
SELECT 
    (SELECT id FROM logged_in_user),
    'Konya''da Arsa Arıyorum',
    'Arsa',
    'Satılık',
    10000000,
    20000000,
    'Selçuklu, Konya',
    '-',
    'active',
    NOW()
RETURNING id, title, budget, max_budget, district, category;

-- 4. Mert Yılmaz'ın portföylerini listele
SELECT 
    'Mert Yilmaz Portfolios' as info,
    p.id as portfolio_id,
    p.title,
    p.category,
    p.type,
    p.price,
    p.district
FROM portfolios p
JOIN profiles pr ON p.user_id = pr.id
WHERE pr.name ILIKE '%mert%yilmaz%'
LIMIT 5;

-- 5. EŞLEŞME OLUŞTUR: Senin Talebin + Mert Yılmaz'ın Portföyü
WITH logged_in_user AS (
  SELECT id FROM auth.users ORDER BY last_sign_in_at DESC LIMIT 1
),
mert_user AS (
  SELECT p.id 
  FROM profiles p 
  WHERE p.name ILIKE '%mert%yilmaz%' 
  LIMIT 1
),
my_new_demand AS (
  SELECT id 
  FROM demands 
  WHERE user_id = (SELECT id FROM logged_in_user)
    AND title = 'Konya''da Arsa Arıyorum'
  ORDER BY created_at DESC
  LIMIT 1
),
mert_portfolio AS (
  SELECT id 
  FROM portfolios 
  WHERE user_id = (SELECT id FROM mert_user)
    AND category = 'Arsa'
  ORDER BY created_at DESC
  LIMIT 1
)
INSERT INTO matches (demand_id, portfolio_id, score, status, created_at)
SELECT 
  (SELECT id FROM my_new_demand),
  (SELECT id FROM mert_portfolio),
  92 as score,
  'pending' as status,
  NOW()
WHERE EXISTS (SELECT 1 FROM my_new_demand)
  AND EXISTS (SELECT 1 FROM mert_portfolio)
RETURNING 
  id as match_id,
  demand_id,
  portfolio_id,
  score,
  status,
  created_at;

-- 6. Oluşturulan eşleşmeyi detaylı göster
SELECT 
    m.id as match_id,
    m.score,
    m.status,
    m.created_at,
    d.title as demand_title,
    d.category as demand_category,
    d.budget as demand_budget,
    d.max_budget as demand_max_budget,
    d.district as demand_district,
    d.user_id as demand_user_id,
    du.email as demand_user_email,
    (SELECT name FROM profiles WHERE id = du.id) as demand_user_name,
    p.title as portfolio_title,
    p.category as portfolio_category,
    p.type as portfolio_type,
    p.price as portfolio_price,
    p.district as portfolio_district,
    p.user_id as portfolio_user_id,
    pu.email as portfolio_user_email,
    (SELECT name FROM profiles WHERE id = pu.id) as portfolio_user_name
FROM matches m
JOIN demands d ON m.demand_id = d.id
JOIN portfolios p ON m.portfolio_id = p.id
JOIN auth.users du ON d.user_id = du.id
JOIN auth.users pu ON p.user_id = pu.id
WHERE m.status = 'pending'
ORDER BY m.created_at DESC
LIMIT 5;
