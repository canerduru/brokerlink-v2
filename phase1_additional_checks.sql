-- ============================================
-- FAZ 1 EK KONTROLLER
-- ============================================
-- İlk duplicate tespitinden sonra çalıştırılacak sorgular

-- 1. Genel İstatistikler
SELECT 
    'Toplam Match Sayısı' as metric,
    COUNT(*) as value
FROM matches
UNION ALL
SELECT 
    'Unique Demand-Portfolio Çiftleri' as metric,
    COUNT(DISTINCT (demand_id, portfolio_id)) as value
FROM matches
UNION ALL
SELECT 
    'Tahmini Duplicate Sayısı' as metric,
    COUNT(*) - COUNT(DISTINCT (demand_id, portfolio_id)) as value
FROM matches;

-- 2. Status Dağılımı
SELECT 
    status, 
    COUNT(*) as count
FROM matches
GROUP BY status
ORDER BY count DESC;

-- 3. RLS Kontrolü
SELECT 
    tablename, 
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('matches', 'demands', 'portfolios')
ORDER BY tablename;

-- 4. Index Kontrolü
SELECT 
    tablename, 
    indexname
FROM pg_indexes
WHERE schemaname = 'public'
AND tablename IN ('matches', 'demands', 'portfolios')
ORDER BY tablename, indexname;
