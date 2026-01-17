-- ============================================
-- TÜM KULLANICI PROFİLLERİNİ LİSTELE
-- ============================================
-- Bu sorguyu Supabase SQL Editor'da çalıştırın

SELECT 
    p.id,
    p.name,
    p.email,
    p.company,
    p.phone,
    p.title,
    p.created_at,
    -- Trust Score bilgisi
    ts.total_score,
    ts.level_emoji,
    -- İstatistikler
    (SELECT COUNT(*) FROM portfolios WHERE user_id = p.id) as portfolio_count,
    (SELECT COUNT(*) FROM demands WHERE user_id = p.id) as demand_count
FROM profiles p
LEFT JOIN trust_scores ts ON p.id = ts.user_id
ORDER BY p.created_at DESC
LIMIT 20;

-- ============================================
-- SADECE CANER DURU PROFİLİ
-- ============================================

SELECT 
    p.id,
    p.name,
    p.email,
    p.company,
    p.phone,
    p.title,
    p.created_at,
    ts.total_score,
    ts.level_emoji
FROM profiles p
LEFT JOIN trust_scores ts ON p.id = ts.user_id
WHERE p.name ILIKE '%Caner%'
   OR p.email ILIKE '%caner%'
ORDER BY p.created_at DESC;

-- ============================================
-- NOT: Şifreleri göremezsiniz (güvenlik)
-- Şifreler Supabase Auth tablosunda hash'li saklanır
-- ============================================
