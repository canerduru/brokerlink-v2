-- 1. Tablolara eksik sutunlari ekle (Eger yoksa olusturur)
-- PORTFOLIOS tablosu
ALTER TABLE portfolios ADD COLUMN IF NOT EXISTS title TEXT;
ALTER TABLE portfolios ADD COLUMN IF NOT EXISTS type TEXT;
ALTER TABLE portfolios ADD COLUMN IF NOT EXISTS category TEXT;
ALTER TABLE portfolios ADD COLUMN IF NOT EXISTS price BIGINT;
ALTER TABLE portfolios ADD COLUMN IF NOT EXISTS city TEXT;
ALTER TABLE portfolios ADD COLUMN IF NOT EXISTS location TEXT; -- Ilce
ALTER TABLE portfolios ADD COLUMN IF NOT EXISTS district TEXT; -- Mahalle
ALTER TABLE portfolios ADD COLUMN IF NOT EXISTS rooms TEXT;
ALTER TABLE portfolios ADD COLUMN IF NOT EXISTS area TEXT;
ALTER TABLE portfolios ADD COLUMN IF NOT EXISTS age TEXT;

-- DEMANDS tablosu
ALTER TABLE demands ADD COLUMN IF NOT EXISTS title TEXT;
ALTER TABLE demands ADD COLUMN IF NOT EXISTS type TEXT;
ALTER TABLE demands ADD COLUMN IF NOT EXISTS category TEXT;
ALTER TABLE demands ADD COLUMN IF NOT EXISTS budget BIGINT;
ALTER TABLE demands ADD COLUMN IF NOT EXISTS maxBudget BIGINT;
ALTER TABLE demands ADD COLUMN IF NOT EXISTS city TEXT;
ALTER TABLE demands ADD COLUMN IF NOT EXISTS location TEXT; -- Ilce
ALTER TABLE demands ADD COLUMN IF NOT EXISTS district TEXT; -- Mahalle 1
ALTER TABLE demands ADD COLUMN IF NOT EXISTS district2 TEXT; -- Mahalle 2
ALTER TABLE demands ADD COLUMN IF NOT EXISTS district3 TEXT; -- Mahalle 3
ALTER TABLE demands ADD COLUMN IF NOT EXISTS rooms TEXT;
ALTER TABLE demands ADD COLUMN IF NOT EXISTS isUrgent BOOLEAN;

-- 2. Mevcut test verilerini temizle (opsiyonel)
-- DELETE FROM portfolios WHERE user_id = 'YOUR_TEST_USER_ID';
-- DELETE FROM demands WHERE user_id = 'YOUR_TEST_USER_ID';

-- 3. Test portföyleri ekle
INSERT INTO portfolios (user_id, title, type, category, price, city, location, district, rooms, area, age, created_at)
VALUES 
  ('a4c5c4e2-7450-4ba8-929b-6053e23ebe65', 'Deniz Manzaralı Villa', 'Satılık', 'Villa', 85000000, 'MUĞLA', 'BODRUM', 'YALIKAVAK', '4+1', '350', '5', NOW()),
  ('a4c5c4e2-7450-4ba8-929b-6053e23ebe65', 'Lüks Daire', 'Satılık', 'Daire', 12000000, 'İSTANBUL', 'BEŞİKTAŞ', 'BEBEK', '3+1', '180', '2', NOW()),
  ('a4c5c4e2-7450-4ba8-929b-6053e23ebe65', 'Havuzlu Villa', 'Satılık', 'Villa', 95000000, 'MUĞLA', 'BODRUM', 'GÜMÜŞLÜK', '5+2', '400', '3', NOW());

-- 4. Test talepleri ekle
INSERT INTO demands (user_id, title, type, category, budget, maxBudget, city, location, district, district2, district3, rooms, isUrgent, created_at)
VALUES 
  ('a4c5c4e2-7450-4ba8-929b-6053e23ebe65', 'Bodrum''da Villa Arıyorum', 'Satılık', 'Villa', 70000000, 100000000, 'MUĞLA', 'BODRUM', 'YALIKAVAK', 'TÜRKBÜKÜ', 'GÜMÜŞLÜK', '4+1', true, NOW()),
  ('a4c5c4e2-7450-4ba8-929b-6053e23ebe65', 'Beşiktaş''ta Daire', 'Satılık', 'Daire', 10000000, 15000000, 'İSTANBUL', 'BEŞİKTAŞ', 'BEBEK', 'ETİLER', 'ULUS', '3+1', false, NOW());
