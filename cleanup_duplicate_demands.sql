-- ============================================
-- DUPLICATE DEMAND TEMIZLEME (SIMPLIFIED)
-- ============================================

-- ADIM 1: BACKUP OLUSTUR
CREATE TABLE IF NOT EXISTS demands_backup_20260111 AS 
SELECT * FROM demands WHERE title ILIKE '%suadiye%';

CREATE TABLE IF NOT EXISTS matches_backup2_20260111 AS 
SELECT * FROM matches WHERE demand_id IN (
    SELECT id FROM demands WHERE title ILIKE '%suadiye%'
);

SELECT 
    'BACKUP OLUSTURULDU' as status,
    (SELECT COUNT(*) FROM demands_backup_20260111) as demand_backup_count,
    (SELECT COUNT(*) FROM matches_backup2_20260111) as match_backup_count;

-- ADIM 2: SILINECEK DEMANDLERI BELIRLE
WITH ranked_demands AS (
    SELECT 
        id,
        title,
        created_at,
        ROW_NUMBER() OVER (
            PARTITION BY user_id, LOWER(title)
            ORDER BY created_at DESC
        ) as rn
    FROM demands
    WHERE title ILIKE '%suadiye%'
)
SELECT 
    'SILINECEK DEMANDLER' as info,
    id,
    title,
    created_at
FROM ranked_demands
WHERE rn > 1
ORDER BY created_at;

-- ADIM 3: TRANSACTION BASLAT
BEGIN;

-- Silinecek demandlere ait matchleri sil
DELETE FROM matches
WHERE demand_id IN (
    WITH ranked_demands AS (
        SELECT 
            id,
            ROW_NUMBER() OVER (
                PARTITION BY user_id, LOWER(title)
                ORDER BY created_at DESC
            ) as rn
        FROM demands
        WHERE title ILIKE '%suadiye%'
    )
    SELECT id FROM ranked_demands WHERE rn > 1
);

-- Duplicate demandleri sil
WITH ranked_demands AS (
    SELECT 
        id,
        ROW_NUMBER() OVER (
            PARTITION BY user_id, LOWER(title)
            ORDER BY created_at DESC
        ) as rn
    FROM demands
    WHERE title ILIKE '%suadiye%'
)
DELETE FROM demands
WHERE id IN (
    SELECT id FROM ranked_demands WHERE rn > 1
);

-- Sonuc kontrolu
SELECT 
    'TEMIZLEME TAMAMLANDI' as status,
    COUNT(*) as kalan_suadiye_talep_sayisi
FROM demands
WHERE title ILIKE '%suadiye%';

-- Eger sonuc 1 ise COMMIT, degilse ROLLBACK
COMMIT;

-- FINAL KONTROL
SELECT 'FINAL DURUM' as info;

SELECT 
    'Suadiye Talep Sayisi' as check_name,
    COUNT(*) as value
FROM demands
WHERE title ILIKE '%suadiye%';

SELECT 
    'Suadiye Match Sayisi' as check_name,
    COUNT(*) as value
FROM matches m
INNER JOIN demands d ON d.id = m.demand_id
WHERE d.title ILIKE '%suadiye%';

-- Kalan eslesmeleri goster
SELECT 
    'KALAN SUADIYE ESLESMELER' as info,
    m.id as match_id,
    m.demand_id,
    d.title as demand_title,
    m.status
FROM matches m
INNER JOIN demands d ON d.id = m.demand_id
WHERE d.title ILIKE '%suadiye%';
