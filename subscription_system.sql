-- ============================================================
-- BROKERLINK: ABONELİK PAKETİ & KULLANIM LİMİTİ SİSTEMİ
-- Bu dosyayı Supabase SQL Editor'da TEK SEFERİNDE çalıştırın.
-- ============================================================

-- ADIM 1: user_subscriptions tablosunu oluştur
CREATE TABLE IF NOT EXISTS user_subscriptions (
    id                  UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id             UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    tier                TEXT        NOT NULL DEFAULT 'free' CHECK (tier IN ('free', 'pro', 'enterprise')),
    demands_used        INTEGER     NOT NULL DEFAULT 0,
    portfolios_used     INTEGER     NOT NULL DEFAULT 0,
    billing_cycle_start TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at          TIMESTAMPTZ DEFAULT NOW(),
    updated_at          TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- ADIM 2: RLS aktif et
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;

-- Kullanıcı kendi aboneliğini görebilir
DROP POLICY IF EXISTS "Users can view own subscription" ON user_subscriptions;
CREATE POLICY "Users can view own subscription"
ON user_subscriptions FOR SELECT
TO authenticated
USING (user_id = auth.uid() OR is_admin());

-- Sadece sistem (SECURITY DEFINER fonksiyonlar) yazabilir
DROP POLICY IF EXISTS "System manages subscriptions" ON user_subscriptions;
CREATE POLICY "System manages subscriptions"
ON user_subscriptions FOR ALL
TO authenticated
USING (is_admin())
WITH CHECK (is_admin());

-- ADIM 3: Mevcut kullanıcılar için abonelik kaydı oluştur
INSERT INTO user_subscriptions (user_id)
SELECT id FROM profiles
ON CONFLICT (user_id) DO NOTHING;

-- ADIM 4: Yeni kayıt olan kullanıcılar için otomatik trigger
CREATE OR REPLACE FUNCTION create_subscription_on_signup()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    INSERT INTO user_subscriptions (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_profile_created_subscription ON profiles;
CREATE TRIGGER on_profile_created_subscription
    AFTER INSERT ON profiles
    FOR EACH ROW EXECUTE FUNCTION create_subscription_on_signup();

-- ADIM 5: Paket limitlerini döndüren yardımcı fonksiyon
CREATE OR REPLACE FUNCTION get_tier_limit(tier_name TEXT)
RETURNS INTEGER LANGUAGE sql IMMUTABLE SECURITY DEFINER AS $$
    SELECT CASE tier_name
        WHEN 'free'       THEN 2
        WHEN 'pro'        THEN 10
        WHEN 'enterprise' THEN 50
        ELSE 2
    END;
$$;

-- ADIM 6: Talep ekleme (quota kontrollü)
CREATE OR REPLACE FUNCTION add_demand_with_quota(demand_data JSONB)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    sub         RECORD;
    tier_limit  INTEGER;
    new_demand  RECORD;
BEGIN
    -- Abonelik kaydı yoksa oluştur
    INSERT INTO user_subscriptions (user_id)
    VALUES (auth.uid())
    ON CONFLICT (user_id) DO NOTHING;

    -- Aboneliği al
    SELECT * INTO sub FROM user_subscriptions WHERE user_id = auth.uid();

    -- 30 günlük dönem bittiyse sayaçları sıfırla
    IF sub.billing_cycle_start < NOW() - INTERVAL '30 days' THEN
        UPDATE user_subscriptions
        SET demands_used = 0, portfolios_used = 0, billing_cycle_start = NOW(), updated_at = NOW()
        WHERE user_id = auth.uid();
        sub.demands_used := 0;
    END IF;

    -- Limit kontrolü
    tier_limit := get_tier_limit(sub.tier);
    IF sub.demands_used >= tier_limit THEN
        RAISE EXCEPTION 'QUOTA_EXCEEDED Ayl%k talep limitinize ula%t%n%z (%%/%%). Paketi y%kseltmek i%in bize ula%%n.',
            sub.demands_used, tier_limit
            USING ERRCODE = 'P0001';
    END IF;

    -- Talebi ekle
    INSERT INTO demands (
        user_id, title, type, category, budget, max_budget, city,
        location, district, district2, district3, rooms, is_urgent, status, match_count
    ) VALUES (
        auth.uid(),
        demand_data->>'title',
        demand_data->>'type',
        demand_data->>'category',
        (demand_data->>'budget')::INTEGER,
        NULLIF(demand_data->>'max_budget', '')::INTEGER,
        NULLIF(demand_data->>'city', ''),
        NULLIF(demand_data->>'location', ''),
        NULLIF(demand_data->>'district', ''),
        NULLIF(demand_data->>'district2', ''),
        NULLIF(demand_data->>'district3', ''),
        COALESCE(NULLIF(demand_data->>'rooms', ''), '-'),
        COALESCE((demand_data->>'is_urgent')::BOOLEAN, false),
        'active',
        0
    )
    RETURNING * INTO new_demand;

    -- Sayacı artır (silse bile geri gelmez)
    UPDATE user_subscriptions
    SET demands_used = demands_used + 1, updated_at = NOW()
    WHERE user_id = auth.uid();

    RETURN row_to_json(new_demand)::JSONB;
END;
$$;

-- ADIM 7: Portföy ekleme (quota kontrollü)
CREATE OR REPLACE FUNCTION add_portfolio_with_quota(portfolio_data JSONB)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    sub            RECORD;
    tier_limit     INTEGER;
    new_portfolio  RECORD;
BEGIN
    -- Abonelik kaydı yoksa oluştur
    INSERT INTO user_subscriptions (user_id)
    VALUES (auth.uid())
    ON CONFLICT (user_id) DO NOTHING;

    -- Aboneliği al
    SELECT * INTO sub FROM user_subscriptions WHERE user_id = auth.uid();

    -- 30 günlük dönem bittiyse sayaçları sıfırla
    IF sub.billing_cycle_start < NOW() - INTERVAL '30 days' THEN
        UPDATE user_subscriptions
        SET demands_used = 0, portfolios_used = 0, billing_cycle_start = NOW(), updated_at = NOW()
        WHERE user_id = auth.uid();
        sub.portfolios_used := 0;
    END IF;

    -- Limit kontrolü
    tier_limit := get_tier_limit(sub.tier);
    IF sub.portfolios_used >= tier_limit THEN
        RAISE EXCEPTION 'QUOTA_EXCEEDED Ayl%k portf%y limitinize ula%t%n%z (%%/%%). Paketi y%kseltmek i%in bize ula%%n.',
            sub.portfolios_used, tier_limit
            USING ERRCODE = 'P0001';
    END IF;

    -- Portföyü ekle
    INSERT INTO portfolios (
        user_id, title, price, type, category, rooms, city, district, area, age, image_url
    ) VALUES (
        auth.uid(),
        portfolio_data->>'title',
        (portfolio_data->>'price')::INTEGER,
        COALESCE(NULLIF(portfolio_data->>'type', ''), 'Satılık'),
        portfolio_data->>'category',
        COALESCE(NULLIF(portfolio_data->>'rooms', ''), '-'),
        NULLIF(portfolio_data->>'city', ''),
        NULLIF(portfolio_data->>'district', ''),
        NULLIF(portfolio_data->>'area', ''),
        NULLIF(portfolio_data->>'age', ''),
        COALESCE(
            NULLIF(portfolio_data->>'image_url', ''),
            'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=800&q=80'
        )
    )
    RETURNING * INTO new_portfolio;

    -- Sayacı artır (silse bile geri gelmez)
    UPDATE user_subscriptions
    SET portfolios_used = portfolios_used + 1, updated_at = NOW()
    WHERE user_id = auth.uid();

    RETURN row_to_json(new_portfolio)::JSONB;
END;
$$;

-- ADIM 8: Kendi abonelik bilgisini çek (frontend)
CREATE OR REPLACE FUNCTION get_my_subscription()
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
    sub RECORD;
    result JSONB;
BEGIN
    SELECT * INTO sub FROM user_subscriptions WHERE user_id = auth.uid();

    IF NOT FOUND THEN
        INSERT INTO user_subscriptions (user_id) VALUES (auth.uid())
        ON CONFLICT (user_id) DO NOTHING;
        SELECT * INTO sub FROM user_subscriptions WHERE user_id = auth.uid();
    END IF;

    -- Dönem bittiyse sıfırla
    IF sub.billing_cycle_start < NOW() - INTERVAL '30 days' THEN
        UPDATE user_subscriptions
        SET demands_used = 0, portfolios_used = 0, billing_cycle_start = NOW(), updated_at = NOW()
        WHERE user_id = auth.uid()
        RETURNING * INTO sub;
    END IF;

    SELECT jsonb_build_object(
        'tier',              sub.tier,
        'demands_used',      sub.demands_used,
        'portfolios_used',   sub.portfolios_used,
        'demands_limit',     get_tier_limit(sub.tier),
        'portfolios_limit',  get_tier_limit(sub.tier),
        'billing_cycle_start', sub.billing_cycle_start
    ) INTO result;

    RETURN result;
END;
$$;

-- ADIM 9: Admin — Tier güncelleme
CREATE OR REPLACE FUNCTION admin_update_tier(target_user_id UUID, new_tier TEXT)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    IF NOT is_admin() THEN
        RAISE EXCEPTION 'Yetkisiz erişim';
    END IF;
    IF new_tier NOT IN ('free', 'pro', 'enterprise') THEN
        RAISE EXCEPTION 'Geçersiz paket adı';
    END IF;
    UPDATE user_subscriptions
    SET tier = new_tier, updated_at = NOW()
    WHERE user_id = target_user_id;
END;
$$;

-- ADIM 10: Admin — Kota sıfırlama
CREATE OR REPLACE FUNCTION admin_reset_quota(target_user_id UUID)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    IF NOT is_admin() THEN
        RAISE EXCEPTION 'Yetkisiz erişim';
    END IF;
    UPDATE user_subscriptions
    SET demands_used = 0, portfolios_used = 0, billing_cycle_start = NOW(), updated_at = NOW()
    WHERE user_id = target_user_id;
END;
$$;

SELECT 'Abonelik sistemi başarıyla kuruldu!' AS status;
