-- Test Data: Portfolio Matches
-- Bu script senin portföyünle eşleşecek başka kullanıcıların taleplerini oluşturur

-- 1. Test kullanıcısı oluştur (eğer yoksa)
-- Not: Supabase auth.users tablosuna direkt insert yapamayız, bu yüzden mevcut bir kullanıcı ID'si kullanacağız
-- Önce mevcut kullanıcıları görelim:
-- SELECT id, email FROM auth.users;

-- 2. Senin mevcut portföylerini kontrol et
-- SELECT id, title, type, category, city, district, rooms, price, user_id FROM portfolios WHERE user_id = auth.uid();

-- 3. Test için: Başka bir kullanıcının senin portföyünle eşleşecek talep oluşturması
-- Örnek: Senin bir "Satılık Villa" portföyün varsa, başka biri "Villa arıyorum" talebi oluşturacak

-- ADIM 1: İkinci kullanıcı ID'sini al (veya oluştur)
-- Eğer ikinci kullanıcı yoksa, Supabase Dashboard'dan manuel oluşturmalısın
-- Şimdilik placeholder kullanıyorum

DO $$
DECLARE
    current_user_id UUID;
    other_user_id UUID;
    test_portfolio_id UUID;
    test_demand_id UUID;
BEGIN
    -- Mevcut kullanıcı (sen)
    current_user_id := auth.uid();
    
    -- İkinci kullanıcı ID'si (gerçek bir kullanıcı olmalı)
    -- Bu ID'yi değiştir! Supabase Dashboard > Authentication > Users'dan al
    -- Örnek: other_user_id := 'BURAYA-GERÇEK-USER-ID-YAZ'::uuid;
    
    -- Geçici çözüm: Mevcut kullanıcılardan birini seç
    SELECT id INTO other_user_id 
    FROM auth.users 
    WHERE id != current_user_id 
    LIMIT 1;
    
    IF other_user_id IS NULL THEN
        RAISE NOTICE 'İkinci kullanıcı bulunamadı! Lütfen Supabase Dashboard''dan yeni kullanıcı oluşturun.';
        RETURN;
    END IF;
    
    RAISE NOTICE 'Current User: %, Other User: %', current_user_id, other_user_id;
    
    -- Senin bir portföyünü seç
    SELECT id INTO test_portfolio_id 
    FROM portfolios 
    WHERE user_id = current_user_id 
    LIMIT 1;
    
    IF test_portfolio_id IS NULL THEN
        RAISE NOTICE 'Portföy bulunamadı! Önce portföy oluşturun.';
        RETURN;
    END IF;
    
    -- O portföyle eşleşecek bir talep oluştur (başka kullanıcı adına)
    INSERT INTO demands (
        user_id,
        title,
        type,
        category,
        city,
        district,
        rooms,
        budget,
        max_budget,
        created_at
    )
    SELECT 
        other_user_id,
        'Test Talep - ' || p.title,
        p.type,
        p.category,
        p.city,
        p.district,
        p.rooms,
        p.price * 0.9, -- Biraz daha düşük bütçe
        p.price * 1.1, -- Biraz daha yüksek max bütçe
        NOW()
    FROM portfolios p
    WHERE p.id = test_portfolio_id
    RETURNING id INTO test_demand_id;
    
    RAISE NOTICE 'Test demand created: %', test_demand_id;
    
    -- Eşleşme oluştur
    INSERT INTO matches (
        demand_id,
        portfolio_id,
        score,
        status,
        created_at
    ) VALUES (
        test_demand_id,
        test_portfolio_id,
        95, -- Yüksek skor
        'pending',
        NOW()
    );
    
    RAISE NOTICE 'Match created successfully!';
    
END $$;

-- Sonuçları kontrol et:
-- SELECT 
--     m.id,
--     m.score,
--     d.title as demand_title,
--     d.user_id as demand_user,
--     p.title as portfolio_title,
--     p.user_id as portfolio_user
-- FROM matches m
-- JOIN demands d ON m.demand_id = d.id
-- JOIN portfolios p ON m.portfolio_id = p.id
-- WHERE p.user_id = auth.uid();
