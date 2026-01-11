-- ============================================
-- MATCH IMPROVEMENTS - FINAL IMPLEMENTATION (FIXED)
-- ============================================
-- Sadece mevcut tablolarla çalışır: matches, demands, portfolios
-- ============================================

-- ============================================
-- FAZ 2: DUPLICATE TEMİZLEME
-- ============================================

-- ADIM 1: Backup Oluştur (Güvenlik)
CREATE TABLE IF NOT EXISTS matches_backup_20260111 AS 
SELECT * FROM matches;

-- Backup doğrulama
SELECT 
    '✅ BACKUP OLUŞTURULDU' as status,
    COUNT(*) as backup_row_count 
FROM matches_backup_20260111;

-- ADIM 2: Silinecek Kayıtları Önizle
WITH ranked_matches AS (
    SELECT 
        id,
        demand_id,
        portfolio_id,
        status,
        created_at,
        ROW_NUMBER() OVER (
            PARTITION BY demand_id, portfolio_id 
            ORDER BY 
                -- Öncelik: approved > pending > rejected
                CASE status 
                    WHEN 'approved' THEN 1
                    WHEN 'pending' THEN 2
                    WHEN 'rejected' THEN 3
                    ELSE 4
                END,
                -- Aynı status'te en yeni olanı tut
                created_at DESC
        ) as rn
    FROM matches
)
SELECT 
    '⚠️ SİLİNECEK KAYITLAR (ÖNİZLEME)' as info,
    id,
    demand_id,
    portfolio_id,
    status,
    created_at
FROM ranked_matches
WHERE rn > 1
ORDER BY demand_id, portfolio_id;

-- ADIM 3: Duplicate Temizleme (TRANSACTION İÇİNDE)
BEGIN;

-- Temizleme işlemi
WITH ranked_matches AS (
    SELECT 
        id,
        ROW_NUMBER() OVER (
            PARTITION BY demand_id, portfolio_id 
            ORDER BY 
                CASE status 
                    WHEN 'approved' THEN 1
                    WHEN 'pending' THEN 2
                    WHEN 'rejected' THEN 3
                    ELSE 4
                END,
                created_at DESC
        ) as rn
    FROM matches
)
DELETE FROM matches
WHERE id IN (
    SELECT id FROM ranked_matches WHERE rn > 1
);

-- Sonuç kontrolü
SELECT 
    '✅ TEMİZLEME TAMAMLANDI' as status,
    COUNT(*) as kalan_match_sayisi,
    COUNT(DISTINCT (demand_id, portfolio_id)) as unique_ciftler
FROM matches;

-- ⚠️ KONTROL: Yukarıdaki sayılar eşit olmalı!
-- Eğer eşitse: COMMIT; (aşağıdaki satır çalışacak)
-- Eğer değilse: ROLLBACK; kullanın

COMMIT;
-- ROLLBACK; -- Sorun varsa bunu kullan

-- ============================================
-- FAZ 3: EK INDEXLER (Performans İyileştirme)
-- ============================================

-- Composite index (duplicate kontrolü için)
CREATE INDEX IF NOT EXISTS idx_matches_demand_portfolio 
ON matches(demand_id, portfolio_id);

-- Index doğrulama
SELECT 
    '✅ INDEXLER OLUŞTURULDU' as status,
    tablename, 
    indexname
FROM pg_indexes
WHERE schemaname = 'public'
AND tablename = 'matches'
AND indexname LIKE 'idx_%'
ORDER BY indexname;

-- ============================================
-- FAZ 4: RLS GÜVENLİK KONTROLÜ
-- ============================================

-- RLS'i aktifleştir (zaten aktifse hata vermez)
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE demands ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolios ENABLE ROW LEVEL SECURITY;

-- RLS durumunu kontrol et
SELECT 
    '✅ RLS DURUMU' as status,
    tablename, 
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('matches', 'demands', 'portfolios')
ORDER BY tablename;

-- Mevcut politikaları kontrol et
SELECT 
    '📋 MEVCUT POLİTİKALAR' as info,
    tablename, 
    policyname,
    cmd as command
FROM pg_policies
WHERE tablename IN ('matches', 'demands', 'portfolios')
ORDER BY tablename, policyname;

-- ============================================
-- FİNAL DOĞRULAMA
-- ============================================

SELECT '=== 🎯 FİNAL DURUM ÖZETİ ===' as info;

-- 1. Duplicate kontrolü
SELECT 
    '1️⃣ Duplicate Kontrolü' as check_name,
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT (demand_id, portfolio_id)) 
        THEN '✅ TEMİZ - Duplicate yok'
        ELSE '⚠️ SORUN - Hala duplicate var: ' || (COUNT(*) - COUNT(DISTINCT (demand_id, portfolio_id)))::text
    END as status,
    COUNT(*) as total_matches,
    COUNT(DISTINCT (demand_id, portfolio_id)) as unique_pairs
FROM matches;

-- 2. Status dağılımı
SELECT 
    '2️⃣ Status Dağılımı' as info,
    status,
    COUNT(*) as count
FROM matches
GROUP BY status
ORDER BY count DESC;

-- 3. Index kontrolü
SELECT 
    '3️⃣ Index Kontrolü' as check_name,
    'Matches tablosu için ' || COUNT(*) || ' index mevcut' as status
FROM pg_indexes
WHERE tablename = 'matches' AND indexname LIKE 'idx_%';

-- 4. RLS kontrolü
SELECT 
    '4️⃣ RLS Kontrolü' as check_name,
    CASE 
        WHEN bool_and(rowsecurity) 
        THEN '✅ TÜM TABLOLARDA AKTİF'
        ELSE '⚠️ BAZI TABLOLARDA KAPALI'
    END as status
FROM pg_tables
WHERE tablename IN ('matches', 'demands', 'portfolios');

-- ============================================
-- TAMAMLANDI! 🎉
-- ============================================
-- Sonraki adımlar:
-- 1. Frontend'i test edin (sayfayı yenileyin: Cmd+Shift+R)
-- 2. Eşleşmeler sekmesini kontrol edin
-- 3. "Onaylanan" tab'ına bakın
-- 4. Badge sayılarını doğrulayın
-- 5. Console'da hata var mı kontrol edin
-- ============================================

-- Backup'ı silmek için (her şey yolundaysa):
-- DROP TABLE IF EXISTS matches_backup_20260111;
