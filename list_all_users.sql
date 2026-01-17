-- TÜM KULLANICILARI LİSTELE
-- Portföy ve talep sayılarıyla birlikte

SELECT 
    p.id,
    p.name,
    p.email,
    p.company,
    p.created_at,
    COUNT(DISTINCT po.id) as portfolio_count,
    COUNT(DISTINCT d.id) as demand_count,
    CASE 
        WHEN p.email LIKE '%@gmail.com%' AND p.name NOT LIKE '%Test%' AND p.name NOT LIKE '%Mert%' AND p.name NOT LIKE '%Ahmet%' THEN 'GERÇEK KULLANICI'
        ELSE 'TEST KULLANICI'
    END as user_type
FROM profiles p
LEFT JOIN portfolios po ON p.id = po.user_id
LEFT JOIN demands d ON p.id = d.user_id
GROUP BY p.id, p.name, p.email, p.company, p.created_at
ORDER BY p.created_at ASC;
