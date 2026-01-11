-- ============================================
-- MATCH IMPROVEMENTS - COMPLETE IMPLEMENTATION
-- ============================================
-- Bu script tüm fazları güvenli bir şekilde uygular.
-- Her adımda sonuçlar gösterilir ve onay beklenir.
-- 
-- KULLANIM:
-- 1. Tüm script'i Supabase SQL Editor'a kopyalayın
-- 2. Adım adım çalıştırın (her bölümü ayrı ayrı seçip Run)
-- 3. Her adımın sonucunu kontrol edin
-- 
-- ⚠️ ÖNEMLİ: Tüm script'i bir seferde çalıştırmayın!
-- Her bölümü ayrı ayrı çalıştırıp sonuçları kontrol edin.
-- ============================================

-- ============================================
-- FAZ 1: ANALİZ (RİSKSİZ - SADECE OKUMA)
-- ============================================

-- ADIM 1.1: Duplicate Tespiti
-- Sonuç: Eğer satır dönerse, duplicate var demektir
SELECT 
    '=== DUPLICATE KAYITLAR ===' as info,
    demand_id, 
    portfolio_id, 
    COUNT(*) as duplicate_count,
    array_agg(id ORDER BY created_at DESC) as match_ids,
    array_agg(status ORDER BY created_at DESC) as statuses
FROM matches
GROUP BY demand_id, portfolio_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- ADIM 1.2: Genel İstatistikler
SELECT '=== GENEL İSTATİSTİKLER ===' as info;

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

-- ADIM 1.3: Status Dağılımı
SELECT 
    '=== STATUS DAĞILIMI ===' as info,
    status, 
    COUNT(*) as count
FROM matches
GROUP BY status
ORDER BY count DESC;

-- ADIM 1.4: RLS Kontrolü
SELECT 
    '=== RLS DURUMU ===' as info,
    tablename, 
    rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('matches', 'demands', 'portfolios')
ORDER BY tablename;

-- ADIM 1.5: Index Kontrolü
SELECT 
    '=== MEVCUT INDEXLER ===' as info,
    tablename, 
    indexname
FROM pg_indexes
WHERE schemaname = 'public'
AND tablename IN ('matches', 'demands', 'portfolios')
ORDER BY tablename, indexname;

-- ============================================
-- FAZ 1 SONUÇ: Yukarıdaki sonuçları kontrol edin
-- - Duplicate var mı? → Faz 2'ye geçin
-- - RLS false mu? → Faz 4'e dikkat
-- - Index eksik mi? → Faz 3'e geçin
-- ============================================


-- ============================================
-- FAZ 2: DUPLICATE TEMİZLEME (ORTA RİSK)
-- ============================================
-- ⚠️ Bu bölümü çalıştırmadan önce:
-- 1. Faz 1 sonuçlarını kontrol edin
-- 2. Duplicate varsa devam edin
-- 3. Yoksa bu bölümü atlayın
-- ============================================

-- ADIM 2.1: Backup Oluştur
CREATE TABLE IF NOT EXISTS matches_backup_20260111 AS 
SELECT * FROM matches;

-- Backup kontrolü
SELECT 
    '=== BACKUP OLUŞTURULDU ===' as info,
    COUNT(*) as backup_count 
FROM matches_backup_20260111;

-- ADIM 2.2: Silinecek Kayıtları Önizle (TEST)
-- Bu sorgu sadece gösterir, silmez
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
SELECT 
    '=== SİLİNECEK KAYITLAR (ÖNİZLEME) ===' as info,
    COUNT(*) as will_be_deleted
FROM ranked_matches
WHERE rn > 1;

-- ADIM 2.3: Duplicate Temizleme (GERÇEK İŞLEM)
-- ⚠️ Bu kısmı çalıştırmadan önce yukarıdaki önizlemeyi kontrol edin!
-- ⚠️ Eğer sayı çok yüksekse DURDURUN ve bana bildirin!

BEGIN; -- Transaction başlat (geri alınabilir)

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
    '=== TEMİZLEME SONUCU ===' as info,
    'Kalan Match Sayısı' as metric,
    COUNT(*) as value
FROM matches
UNION ALL
SELECT 
    '=== TEMİZLEME SONUCU ===' as info,
    'Unique Çiftler' as metric,
    COUNT(DISTINCT (demand_id, portfolio_id)) as value
FROM matches;

-- ⚠️ KONTROL EDİN: Sayılar mantıklı mı?
-- ✅ Eğer her şey doğruysa: COMMIT; çalıştırın
-- ❌ Eğer bir sorun varsa: ROLLBACK; çalıştırın

-- COMMIT; -- Değişiklikleri kaydet (yorumu kaldırın)
-- ROLLBACK; -- Geri al (yorumu kaldırın)

-- ============================================
-- FAZ 2 SONUÇ: 
-- - COMMIT yaptıysanız, duplicate'ler temizlendi
-- - ROLLBACK yaptıysanız, hiçbir şey değişmedi
-- ============================================


-- ============================================
-- FAZ 3: PERFORMANCE INDEXLER (DÜŞÜK RİSK)
-- ============================================

-- ADIM 3.1: Matches Tablosu İndexleri
CREATE INDEX IF NOT EXISTS idx_matches_status 
ON matches(status);

CREATE INDEX IF NOT EXISTS idx_matches_demand_id 
ON matches(demand_id);

CREATE INDEX IF NOT EXISTS idx_matches_portfolio_id 
ON matches(portfolio_id);

-- Composite index (duplicate kontrolü için)
CREATE INDEX IF NOT EXISTS idx_matches_demand_portfolio 
ON matches(demand_id, portfolio_id);

-- ADIM 3.2: Network Sorguları İçin İndexler
CREATE INDEX IF NOT EXISTS idx_portfolios_user_created 
ON portfolios(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_demands_user_created 
ON demands(user_id, created_at DESC);

-- ADIM 3.3: Connections İndexleri
CREATE INDEX IF NOT EXISTS idx_connections_users 
ON connections(requester_id, receiver_id);

CREATE INDEX IF NOT EXISTS idx_connection_requests_receiver 
ON connection_requests(receiver_id, status);

-- Index kontrolü
SELECT 
    '=== OLUŞTURULAN INDEXLER ===' as info,
    tablename, 
    indexname
FROM pg_indexes
WHERE schemaname = 'public'
AND tablename IN ('matches', 'demands', 'portfolios', 'connections', 'connection_requests')
AND indexname LIKE 'idx_%'
ORDER BY tablename, indexname;

-- ============================================
-- FAZ 3 SONUÇ: Indexler oluşturuldu
-- Performans artışı bekleniyor
-- ============================================


-- ============================================
-- FAZ 4: RLS GÜVENLİK KONTROLÜ (YÜKSEK RİSK)
-- ============================================
-- ⚠️ Bu bölüm kritik! Yanlış yapılandırma kullanıcıları bloke edebilir
-- ============================================

-- ADIM 4.1: RLS'i Aktifleştir
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE demands ENABLE ROW LEVEL SECURITY;
ALTER TABLE portfolios ENABLE ROW LEVEL SECURITY;
ALTER TABLE connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE connection_requests ENABLE ROW LEVEL SECURITY;

-- ADIM 4.2: Mevcut Politikaları Kontrol Et
SELECT 
    '=== MEVCUT RLS POLİTİKALARI ===' as info,
    tablename, 
    policyname,
    cmd as command
FROM pg_policies
WHERE tablename IN ('matches', 'demands', 'portfolios', 'connections', 'connection_requests')
ORDER BY tablename, policyname;

-- ============================================
-- NOT: RLS politikaları zaten Supabase tarafından 
-- otomatik oluşturulmuş olabilir. Yukarıdaki sorguyu
-- çalıştırıp mevcut politikaları kontrol edin.
-- 
-- Eğer politika yoksa veya eksikse, aşağıdaki
-- örnekleri kullanarak ekleyebilirsiniz:
-- ============================================

-- ÖRNEK POLİTİKA (Sadece gerekirse kullanın):
/*
-- Matches: Kullanıcı sadece kendi demand veya portfolio'larına ait eşleşmeleri görebilir
CREATE POLICY "Users can view own matches" ON matches
FOR SELECT USING (
    demand_id IN (SELECT id FROM demands WHERE user_id = auth.uid())
    OR
    portfolio_id IN (SELECT id FROM portfolios WHERE user_id = auth.uid())
);

-- Demands: Kullanıcı sadece kendi taleplerini görebilir
CREATE POLICY "Users can view own demands" ON demands
FOR SELECT USING (user_id = auth.uid());

-- Portfolios: Kullanıcı sadece kendi portföylerini görebilir  
CREATE POLICY "Users can view own portfolios" ON portfolios
FOR SELECT USING (user_id = auth.uid());
*/

-- ============================================
-- FAZ 4 SONUÇ: RLS aktif
-- Politikaları kontrol ettiniz
-- ============================================


-- ============================================
-- FİNAL KONTROL: HER ŞEY TAMAMLANDI MI?
-- ============================================

SELECT '=== FİNAL DURUM ÖZETİ ===' as info;

-- 1. Duplicate kontrolü
SELECT 
    'Duplicate Kayıt Var mı?' as check_name,
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT (demand_id, portfolio_id)) 
        THEN '✅ YOK (Temiz)'
        ELSE '⚠️ VAR (Tekrar temizleme gerekebilir)'
    END as status
FROM matches;

-- 2. Index kontrolü
SELECT 
    'Matches Indexleri' as check_name,
    CASE 
        WHEN COUNT(*) >= 4 
        THEN '✅ TAMAM (' || COUNT(*) || ' index)'
        ELSE '⚠️ EKSİK (' || COUNT(*) || ' index)'
    END as status
FROM pg_indexes
WHERE tablename = 'matches' AND indexname LIKE 'idx_%';

-- 3. RLS kontrolü
SELECT 
    'RLS Güvenlik' as check_name,
    CASE 
        WHEN bool_and(rowsecurity) 
        THEN '✅ AKTİF'
        ELSE '⚠️ KAPALI'
    END as status
FROM pg_tables
WHERE tablename IN ('matches', 'demands', 'portfolios');

-- 4. Toplam istatistikler
SELECT 
    'Toplam Matches' as metric,
    COUNT(*) as value
FROM matches
UNION ALL
SELECT 
    'Pending Matches' as metric,
    COUNT(*) as value
FROM matches WHERE status = 'pending'
UNION ALL
SELECT 
    'Approved Matches' as metric,
    COUNT(*) as value
FROM matches WHERE status = 'approved'
UNION ALL
SELECT 
    'Rejected Matches' as metric,
    COUNT(*) as value
FROM matches WHERE status = 'rejected';

-- ============================================
-- TAMAMLANDI! 
-- ============================================
-- Sonuçları kontrol edin ve frontend'i test edin:
-- 1. Sayfayı yenileyin (Cmd+Shift+R)
-- 2. Eşleşmeler sekmesini açın
-- 3. "Onaylanan" tab'ına bakın
-- 4. Badge sayılarını kontrol edin
-- 5. Console'da hata var mı kontrol edin
-- ============================================
