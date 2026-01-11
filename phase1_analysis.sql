-- ============================================
-- FAZ 1: VERİTABANI ANALİZİ (RİSKSİZ)
-- ============================================
-- Bu script sadece OKUMA işlemleri yapar.
-- Hiçbir veri değiştirilmez veya silinmez.

-- ============================================
-- ADIM 1.1: DUPLICATE TESPİTİ
-- ============================================
-- Aynı demand_id + portfolio_id çiftinden birden fazla kayıt var mı?

SELECT 
    demand_id, 
    portfolio_id, 
    COUNT(*) as duplicate_count,
    array_agg(id ORDER BY created_at DESC) as match_ids,
    array_agg(status ORDER BY created_at DESC) as statuses,
    array_agg(created_at ORDER BY created_at DESC) as dates
FROM matches
GROUP BY demand_id, portfolio_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- Beklenen: Eğer duplicate varsa, bu sorgu onları gösterecek
-- Eğer sonuç boşsa: ✅ Temiz, duplicate yok
-- Eğer sonuç varsa: ⚠️ Temizleme gerekli

-- ============================================
-- ADIM 1.2: TOPLAM İSTATİSTİKLER
-- ============================================

-- Toplam match sayısı
SELECT COUNT(*) as total_matches FROM matches;

-- Status dağılımı
SELECT 
    status, 
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM matches), 2) as percentage
FROM matches
GROUP BY status
ORDER BY count DESC;

-- Potansiyel duplicate sayısı (tahmini)
SELECT 
    COUNT(*) - COUNT(DISTINCT (demand_id, portfolio_id)) as estimated_duplicates
FROM matches;

-- ============================================
-- ADIM 1.3: RLS (ROW LEVEL SECURITY) KONTROLÜ
-- ============================================

-- Hangi tablolarda RLS aktif?
SELECT 
    schemaname, 
    tablename, 
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('matches', 'demands', 'portfolios', 'connections', 'connection_requests')
ORDER BY tablename;

-- Beklenen: rowsecurity = true olmalı
-- Eğer false ise: 🔴 GÜVENLİK RİSKİ!

-- ============================================
-- ADIM 1.4: RLS POLİTİKALARI KONTROLÜ
-- ============================================

-- Mevcut RLS politikalarını listele
SELECT 
    schemaname, 
    tablename, 
    policyname, 
    permissive,
    roles,
    cmd as command,
    qual as using_expression,
    with_check as with_check_expression
FROM pg_policies
WHERE tablename IN ('matches', 'demands', 'portfolios', 'connections', 'connection_requests')
ORDER BY tablename, policyname;

-- Beklenen: Her tablo için SELECT, INSERT, UPDATE, DELETE politikaları olmalı
-- Eğer boşsa: 🔴 POLİTİKA EKSİK!

-- ============================================
-- ADIM 1.5: INDEX KONTROLÜ
-- ============================================

-- Mevcut indexleri listele
SELECT 
    tablename, 
    indexname, 
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
AND tablename IN ('matches', 'demands', 'portfolios')
ORDER BY tablename, indexname;

-- Beklenen indexler:
-- matches: idx_matches_status, idx_matches_demand_id, idx_matches_portfolio_id
-- demands: idx_demands_user_created
-- portfolios: idx_portfolios_user_created

-- ============================================
-- ADIM 1.6: PERFORMANS ANALİZİ
-- ============================================

-- En çok eşleşmeye sahip demand'ler
SELECT 
    d.id,
    d.title,
    d.user_id,
    COUNT(m.id) as match_count
FROM demands d
LEFT JOIN matches m ON m.demand_id = d.id
GROUP BY d.id, d.title, d.user_id
ORDER BY match_count DESC
LIMIT 10;

-- En çok eşleşmeye sahip portfolio'lar
SELECT 
    p.id,
    p.title,
    p.user_id,
    COUNT(m.id) as match_count
FROM portfolios p
LEFT JOIN matches m ON m.portfolio_id = p.id
GROUP BY p.id, p.title, p.user_id
ORDER BY match_count DESC
LIMIT 10;

-- ============================================
-- SONUÇ ÖZETİ
-- ============================================
-- Bu script'i çalıştırdıktan sonra:
-- 1. Duplicate sayısını not edin
-- 2. RLS durumunu kontrol edin
-- 3. Eksik indexleri belirleyin
-- 4. Sonuçları bana bildirin, Faz 2'ye geçelim
-- ============================================
