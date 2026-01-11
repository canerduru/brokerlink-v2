-- Dashboard'da neden sadece 1 eşleşme göründüğünü kontrol et

-- Tüm eşleşmeleri tarihe göre sırala
SELECT 
    'TUM ESLESMELER (TARIHE GORE)' as info,
    m.id as match_id,
    m.status,
    m.created_at,
    d.title as demand_title,
    p.title as portfolio_title,
    m.score
FROM matches m
LEFT JOIN demands d ON d.id = m.demand_id
LEFT JOIN portfolios p ON p.id = m.portfolio_id
ORDER BY m.created_at DESC NULLS LAST
LIMIT 10;

-- created_at NULL olanlar var mı?
SELECT 
    'CREATED_AT NULL OLANLAR' as info,
    COUNT(*) as null_count
FROM matches
WHERE created_at IS NULL;
