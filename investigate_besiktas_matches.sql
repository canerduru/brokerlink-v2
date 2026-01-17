-- "Beşiktaş Match Portfolio" Eşleşmelerini Kontrol Et
-- Supabase SQL Editor'da çalıştır

-- 1. Bu portföyü bul
SELECT 
    id,
    title,
    category,
    type,
    price,
    district,
    location,
    city
FROM portfolios
WHERE title = 'Beşiktaş Match Portfolio'
LIMIT 1;

-- 2. Bu portföyün tüm eşleşmelerini listele
SELECT 
    m.id as match_id,
    m.score,
    m.status,
    m.created_at,
    d.id as demand_id,
    d.title as demand_title,
    d.category as demand_category,
    d.budget,
    d.max_budget,
    d.district as demand_district,
    d.user_id as demand_user_id,
    (SELECT name FROM profiles WHERE id = d.user_id) as demand_owner_name
FROM matches m
JOIN demands d ON m.demand_id = d.id
JOIN portfolios p ON m.portfolio_id = p.id
WHERE p.title = 'Beşiktaş Match Portfolio'
ORDER BY m.created_at DESC;

-- 3. Kaç farklı talep var?
SELECT 
    COUNT(DISTINCT m.demand_id) as unique_demands,
    COUNT(*) as total_matches
FROM matches m
JOIN portfolios p ON m.portfolio_id = p.id
WHERE p.title = 'Beşiktaş Match Portfolio';

-- 4. Bu talepler kimler tarafından oluşturulmuş?
SELECT DISTINCT
    d.user_id,
    (SELECT name FROM profiles WHERE id = d.user_id) as owner_name,
    (SELECT email FROM auth.users WHERE id = d.user_id) as owner_email,
    COUNT(*) as demand_count
FROM matches m
JOIN portfolios p ON m.portfolio_id = p.id
JOIN demands d ON m.demand_id = d.id
WHERE p.title = 'Beşiktaş Match Portfolio'
GROUP BY d.user_id;
