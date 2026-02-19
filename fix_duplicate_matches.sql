-- ============================================
-- Fix: Duplicate eşleşmeleri temizle ve UNIQUE constraint ekle
-- ============================================

-- ADIM 1: Mevcut duplicate'leri temizle
-- Her (demand_id, portfolio_id) çifti için en iyi status'u korur:
-- Öncelik: approved > rejected > pending
-- Aynı status'ta olanlardan en yenisi kalır
WITH ranked AS (
    SELECT
        id,
        ROW_NUMBER() OVER (
            PARTITION BY demand_id, portfolio_id
            ORDER BY
                CASE status
                    WHEN 'approved' THEN 1
                    WHEN 'rejected' THEN 2
                    WHEN 'pending'  THEN 3
                    ELSE 4
                END,
                created_at DESC
        ) AS rn
    FROM matches
)
DELETE FROM matches
WHERE id IN (
    SELECT id FROM ranked WHERE rn > 1
);

-- Kaç kayıt silindi kontrol
SELECT 'Duplicate temizleme tamamlandi.' AS status, COUNT(*) AS kalan_eslesme FROM matches;

-- ADIM 2: UNIQUE constraint ekle
-- Önce varsa eski constraint'i temizle
ALTER TABLE matches DROP CONSTRAINT IF EXISTS unique_demand_portfolio;

-- Yeni UNIQUE constraint ekle
ALTER TABLE matches ADD CONSTRAINT unique_demand_portfolio
    UNIQUE (demand_id, portfolio_id);

SELECT 'UNIQUE constraint eklendi!' AS status;
