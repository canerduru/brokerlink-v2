-- Dashboard'da görünecek test eşleşmesi oluştur
-- Supabase SQL Editor'da çalıştır

-- 1. Önce mevcut durumu kontrol et
SELECT 
    'Current User' as info,
    id,
    email,
    (SELECT name FROM profiles WHERE profiles.id = auth.users.id) as name
FROM auth.users 
ORDER BY last_sign_in_at DESC 
LIMIT 1;

-- 2. Başka kullanıcıların taleplerini listele
SELECT 
    'Other Users Demands' as info,
    d.id as demand_id, 
    d.title, 
    d.category,
    d.type,
    d.user_id,
    u.email as user_email
FROM demands d
JOIN auth.users u ON d.user_id = u.id
WHERE d.user_id != (SELECT id FROM auth.users ORDER BY last_sign_in_at DESC LIMIT 1)
  AND d.status = 'active'
LIMIT 5;

-- 3. Senin portföylerini listele
SELECT 
    'My Portfolios' as info,
    p.id as portfolio_id, 
    p.title, 
    p.category,
    p.type,
    p.user_id
FROM portfolios p
WHERE p.user_id = (SELECT id FROM auth.users ORDER BY last_sign_in_at DESC LIMIT 1)
LIMIT 5;

-- 4. TEST EŞLEŞME OLUŞTUR
-- Bu kısım başka kullanıcının talebi ile senin portföyün arasında eşleşme yaratır
WITH logged_in_user AS (
  SELECT id FROM auth.users ORDER BY last_sign_in_at DESC LIMIT 1
),
other_demand AS (
  SELECT id, title, category, type 
  FROM demands 
  WHERE user_id != (SELECT id FROM logged_in_user) 
    AND status = 'active'
  ORDER BY created_at DESC
  LIMIT 1
),
my_portfolio AS (
  SELECT id, title, category, type
  FROM portfolios 
  WHERE user_id = (SELECT id FROM logged_in_user)
  ORDER BY created_at DESC
  LIMIT 1
)
INSERT INTO matches (demand_id, portfolio_id, score, status, created_at)
SELECT 
  od.id as demand_id,
  mp.id as portfolio_id,
  95 as score,
  'pending' as status,
  NOW() as created_at
FROM other_demand od, my_portfolio mp
WHERE EXISTS (SELECT 1 FROM other_demand)
  AND EXISTS (SELECT 1 FROM my_portfolio)
RETURNING 
  id as match_id,
  demand_id,
  portfolio_id,
  score,
  status,
  created_at;

-- 5. Oluşturulan eşleşmeyi detaylı göster
SELECT 
    m.id as match_id,
    m.score,
    m.status,
    m.created_at,
    d.title as demand_title,
    d.category as demand_category,
    d.type as demand_type,
    d.user_id as demand_user_id,
    du.email as demand_user_email,
    p.title as portfolio_title,
    p.category as portfolio_category,
    p.type as portfolio_type,
    p.price as portfolio_price,
    p.user_id as portfolio_user_id,
    pu.email as portfolio_user_email
FROM matches m
JOIN demands d ON m.demand_id = d.id
JOIN portfolios p ON m.portfolio_id = p.id
JOIN auth.users du ON d.user_id = du.id
JOIN auth.users pu ON p.user_id = pu.id
WHERE m.status = 'pending'
ORDER BY m.created_at DESC
LIMIT 5;
