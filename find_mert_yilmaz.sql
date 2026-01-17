-- Mert Yılmaz'ı bul ve kontrol et
-- Supabase SQL Editor'da çalıştır

-- 1. Tüm profilleri listele (Mert Yılmaz var mı?)
SELECT 
    id,
    name,
    email,
    company,
    title
FROM profiles
WHERE name IS NOT NULL
ORDER BY created_at DESC
LIMIT 10;

-- 2. Mert Yılmaz'ı ara (farklı varyasyonlar)
SELECT 
    id,
    name,
    email
FROM profiles
WHERE name ILIKE '%mert%'
   OR name ILIKE '%yilmaz%'
   OR name ILIKE '%yılmaz%'
LIMIT 5;

-- 3. Eğer Mert Yılmaz yoksa, başka bir kullanıcı seç
SELECT 
    id,
    name,
    email,
    company
FROM profiles
WHERE id != (SELECT id FROM auth.users ORDER BY last_sign_in_at DESC LIMIT 1) -- Senin ID'n değil
  AND name IS NOT NULL
LIMIT 5;
