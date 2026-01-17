-- Demands tablosunun yapısını kontrol et
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'demands'
ORDER BY ordinal_position;
