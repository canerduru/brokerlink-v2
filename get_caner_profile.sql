-- Caner Duru profilini bul
SELECT 
    id,
    name,
    email,
    company,
    phone,
    created_at
FROM profiles
WHERE name ILIKE '%Caner%Duru%'
ORDER BY created_at DESC
LIMIT 1;
