-- ============================================
-- TRUST SCORE SYSTEM - DATABASE MIGRATION
-- ============================================
-- This migration creates the complete Trust Score infrastructure
-- including tables, functions, and triggers.

-- ============================================
-- 1. TRUST SCORES TABLE (Main Storage)
-- ============================================
CREATE TABLE IF NOT EXISTS trust_scores (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Scores (0-100 range)
    total_score INTEGER NOT NULL DEFAULT 0 CHECK (total_score >= 0 AND total_score <= 100),
    profile_score INTEGER NOT NULL DEFAULT 0 CHECK (profile_score >= 0 AND profile_score <= 40),
    login_score INTEGER NOT NULL DEFAULT 0 CHECK (login_score >= 0 AND login_score <= 20),
    data_score INTEGER NOT NULL DEFAULT 0 CHECK (data_score >= 0 AND data_score <= 20),
    reaction_score INTEGER NOT NULL DEFAULT 0 CHECK (reaction_score >= 0 AND reaction_score <= 20),
    
    -- Level classification
    level TEXT NOT NULL DEFAULT 'newcomer',
    level_name TEXT NOT NULL DEFAULT 'Başlangıç',
    level_emoji TEXT NOT NULL DEFAULT '🔰',
    
    -- Metadata
    last_active_at TIMESTAMPTZ,
    last_calculated_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE trust_scores ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view all trust scores"
    ON trust_scores FOR SELECT
    USING (true);

CREATE POLICY "Users can update own trust score"
    ON trust_scores FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "System can insert trust scores"
    ON trust_scores FOR INSERT
    WITH CHECK (true);

-- Index for performance
CREATE INDEX IF NOT EXISTS idx_trust_scores_total ON trust_scores(total_score DESC);
CREATE INDEX IF NOT EXISTS idx_trust_scores_level ON trust_scores(level);

-- ============================================
-- 2. TRUST SCORE HISTORY TABLE (Tracking)
-- ============================================
CREATE TABLE IF NOT EXISTS trust_score_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    total_score INTEGER NOT NULL,
    profile_score INTEGER NOT NULL,
    login_score INTEGER NOT NULL,
    data_score INTEGER NOT NULL,
    reaction_score INTEGER NOT NULL,
    level TEXT NOT NULL,
    recorded_at DATE NOT NULL DEFAULT CURRENT_DATE,
    
    CONSTRAINT unique_user_date UNIQUE (user_id, recorded_at)
);

-- Enable RLS
ALTER TABLE trust_score_history ENABLE ROW LEVEL SECURITY;

-- RLS Policy
CREATE POLICY "Users can view own history"
    ON trust_score_history FOR SELECT
    USING (auth.uid() = user_id);

-- Index
CREATE INDEX IF NOT EXISTS idx_trust_history_user_date ON trust_score_history(user_id, recorded_at DESC);

-- ============================================
-- 3. CALCULATE TRUST SCORE FUNCTION
-- ============================================
CREATE OR REPLACE FUNCTION calculate_trust_score(p_user_id UUID)
RETURNS TABLE(
    total INTEGER,
    profile INTEGER,
    login INTEGER,
    data INTEGER,
    reaction INTEGER,
    level TEXT,
    level_name TEXT,
    level_emoji TEXT
) AS $$
DECLARE
    v_profile_score INTEGER := 0;
    v_login_score INTEGER := 0;
    v_data_score INTEGER := 0;
    v_reaction_score INTEGER := 0;
    v_total_score INTEGER := 0;
    v_level TEXT;
    v_level_name TEXT;
    v_level_emoji TEXT;
    v_last_active TIMESTAMPTZ;
    v_days_since_active NUMERIC;
BEGIN
    -- ========================================
    -- 1. PROFILE SCORE (40 points max)
    -- ========================================
    SELECT
        (CASE WHEN avatar_url IS NOT NULL AND avatar_url != '' THEN 10 ELSE 0 END) +
        (CASE WHEN (company IS NOT NULL AND company != '') OR (title IS NOT NULL AND title != '') THEN 10 ELSE 0 END) +
        (CASE WHEN phone IS NOT NULL AND phone != '' THEN 10 ELSE 0 END) +
        (CASE WHEN service_areas IS NOT NULL AND jsonb_array_length(service_areas) > 0 THEN 10 ELSE 0 END)
    INTO v_profile_score
    FROM profiles
    WHERE id = p_user_id;
    
    -- ========================================
    -- 2. LOGIN SCORE (20 points max)
    -- ========================================
    -- Check last_active_at from trust_scores table
    SELECT last_active_at INTO v_last_active
    FROM trust_scores
    WHERE user_id = p_user_id;
    
    IF v_last_active IS NOT NULL THEN
        v_days_since_active := EXTRACT(EPOCH FROM (NOW() - v_last_active)) / 86400;
        IF v_days_since_active <= 5 THEN
            v_login_score := 20;
        ELSE
            v_login_score := 0;
        END IF;
    ELSE
        -- First time calculation, grant points
        v_login_score := 20;
    END IF;
    
    -- ========================================
    -- 3. DATA SCORE (20 points max)
    -- ========================================
    -- Check if user has recent portfolios or demands (last 45 days)
    -- Note: portfolios and demands tables only have created_at, not updated_at
    IF EXISTS (
        SELECT 1 FROM portfolios
        WHERE user_id = p_user_id
        AND created_at >= NOW() - INTERVAL '45 days'
        LIMIT 1
    ) OR EXISTS (
        SELECT 1 FROM demands
        WHERE user_id = p_user_id
        AND created_at >= NOW() - INTERVAL '45 days'
        LIMIT 1
    ) THEN
        v_data_score := 20;
    ELSE
        v_data_score := 0;
    END IF;
    
    -- ========================================
    -- 4. REACTION SCORE (20 points max)
    -- ========================================
    -- Count approved matches + conversations in last 45 days
    -- Fixed: Properly count matches where user is either demand owner or portfolio owner
    WITH user_demand_matches AS (
        SELECT COUNT(DISTINCT m.id) as count
        FROM matches m
        INNER JOIN demands d ON m.demand_id = d.id
        WHERE d.user_id = p_user_id
        AND m.status = 'approved'
        AND m.created_at >= NOW() - INTERVAL '45 days'
    ),
    user_portfolio_matches AS (
        SELECT COUNT(DISTINCT m.id) as count
        FROM matches m
        INNER JOIN portfolios p ON m.portfolio_id = p.id
        WHERE p.user_id = p_user_id
        AND m.status = 'approved'
        AND m.created_at >= NOW() - INTERVAL '45 days'
    ),
    recent_conversations AS (
        SELECT COUNT(*) as conv_count
        FROM conversations
        WHERE user_id = p_user_id
        AND created_at >= NOW() - INTERVAL '45 days'
    )
    SELECT LEAST(20, ((udm.count + upm.count + rc.conv_count) * 2))
    INTO v_reaction_score
    FROM user_demand_matches udm, user_portfolio_matches upm, recent_conversations rc;
    
    -- ========================================
    -- 5. TOTAL SCORE
    -- ========================================
    v_total_score := v_profile_score + v_login_score + v_data_score + v_reaction_score;
    
    -- ========================================
    -- 6. LEVEL DETERMINATION
    -- ========================================
    IF v_total_score >= 90 THEN
        v_level := 'diamond';
        v_level_name := 'Elmas Broker';
        v_level_emoji := '💎';
    ELSIF v_total_score >= 80 THEN
        v_level := 'gold';
        v_level_name := 'Altın Broker';
        v_level_emoji := '🥇';
    ELSIF v_total_score >= 70 THEN
        v_level := 'silver';
        v_level_name := 'Gümüş Broker';
        v_level_emoji := '🥈';
    ELSIF v_total_score >= 60 THEN
        v_level := 'bronze';
        v_level_name := 'Bronz Broker';
        v_level_emoji := '🥉';
    ELSIF v_total_score >= 40 THEN
        v_level := 'rising';
        v_level_name := 'Yükselen Broker';
        v_level_emoji := '⭐';
    ELSE
        v_level := 'newcomer';
        v_level_name := 'Başlangıç';
        v_level_emoji := '🔰';
    END IF;
    
    -- Return results
    RETURN QUERY SELECT 
        v_total_score,
        v_profile_score,
        v_login_score,
        v_data_score,
        v_reaction_score,
        v_level,
        v_level_name,
        v_level_emoji;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 4. UPDATE TRUST SCORE FUNCTION
-- ============================================
CREATE OR REPLACE FUNCTION update_trust_score(
    p_user_id UUID,
    p_update_last_active BOOLEAN DEFAULT FALSE
)
RETURNS void AS $$
DECLARE
    v_score RECORD;
BEGIN
    -- Calculate score
    SELECT * INTO v_score FROM calculate_trust_score(p_user_id);
    
    -- Upsert into trust_scores
    INSERT INTO trust_scores (
        user_id,
        total_score,
        profile_score,
        login_score,
        data_score,
        reaction_score,
        level,
        level_name,
        level_emoji,
        last_active_at,
        last_calculated_at,
        updated_at
    ) VALUES (
        p_user_id,
        v_score.total,
        v_score.profile,
        v_score.login,
        v_score.data,
        v_score.reaction,
        v_score.level,
        v_score.level_name,
        v_score.level_emoji,
        NOW(),
        NOW(),
        NOW()
    )
    ON CONFLICT (user_id) DO UPDATE SET
        total_score = v_score.total,
        profile_score = v_score.profile,
        login_score = v_score.login,
        data_score = v_score.data,
        reaction_score = v_score.reaction,
        level = v_score.level,
        level_name = v_score.level_name,
        level_emoji = v_score.level_emoji,
        last_active_at = CASE 
            WHEN p_update_last_active THEN NOW()
            ELSE COALESCE(trust_scores.last_active_at, NOW())
        END,
        last_calculated_at = NOW(),
        updated_at = NOW();
    
    -- Insert into history (daily snapshot)
    INSERT INTO trust_score_history (
        user_id,
        total_score,
        profile_score,
        login_score,
        data_score,
        reaction_score,
        level,
        recorded_at
    ) VALUES (
        p_user_id,
        v_score.total,
        v_score.profile,
        v_score.login,
        v_score.data,
        v_score.reaction,
        v_score.level,
        CURRENT_DATE
    )
    ON CONFLICT (user_id, recorded_at) DO UPDATE SET
        total_score = v_score.total,
        profile_score = v_score.profile,
        login_score = v_score.login,
        data_score = v_score.data,
        reaction_score = v_score.reaction,
        level = v_score.level;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 5. TRIGGERS FOR AUTO-UPDATE
-- ============================================

-- Trigger on profile updates
CREATE OR REPLACE FUNCTION trigger_update_trust_score_on_profile()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM update_trust_score(NEW.id, FALSE);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_trust_on_profile ON profiles;
CREATE TRIGGER update_trust_on_profile
    AFTER INSERT OR UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION trigger_update_trust_score_on_profile();

-- Trigger on portfolio changes
CREATE OR REPLACE FUNCTION trigger_update_trust_score_on_portfolio()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM update_trust_score(NEW.user_id, FALSE);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_trust_on_portfolio ON portfolios;
CREATE TRIGGER update_trust_on_portfolio
    AFTER INSERT OR UPDATE ON portfolios
    FOR EACH ROW
    EXECUTE FUNCTION trigger_update_trust_score_on_portfolio();

-- Trigger on demand changes
DROP TRIGGER IF EXISTS update_trust_on_demand ON demands;
CREATE TRIGGER update_trust_on_demand
    AFTER INSERT OR UPDATE ON demands
    FOR EACH ROW
    EXECUTE FUNCTION trigger_update_trust_score_on_portfolio();

-- Trigger on match approval
CREATE OR REPLACE FUNCTION trigger_update_trust_score_on_match()
RETURNS TRIGGER AS $$
DECLARE
    v_demand_user_id UUID;
    v_portfolio_user_id UUID;
BEGIN
    -- Get user IDs from demand and portfolio
    SELECT user_id INTO v_demand_user_id FROM demands WHERE id = NEW.demand_id;
    SELECT user_id INTO v_portfolio_user_id FROM portfolios WHERE id = NEW.portfolio_id;
    
    -- Update both users involved in the match
    IF v_demand_user_id IS NOT NULL THEN
        PERFORM update_trust_score(v_demand_user_id, FALSE);
    END IF;
    
    IF v_portfolio_user_id IS NOT NULL THEN
        PERFORM update_trust_score(v_portfolio_user_id, FALSE);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_trust_on_match ON matches;
CREATE TRIGGER update_trust_on_match
    AFTER INSERT OR UPDATE ON matches
    FOR EACH ROW
    EXECUTE FUNCTION trigger_update_trust_score_on_match();

-- ============================================
-- 6. HELPER FUNCTIONS
-- ============================================

-- Get leaderboard (top brokers)
CREATE OR REPLACE FUNCTION get_trust_score_leaderboard(p_limit INTEGER DEFAULT 10)
RETURNS TABLE(
    user_id UUID,
    name TEXT,
    company TEXT,
    avatar_url TEXT,
    total_score INTEGER,
    level TEXT,
    level_emoji TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ts.user_id,
        p.name,
        p.company,
        p.avatar_url,
        ts.total_score,
        ts.level,
        ts.level_emoji
    FROM trust_scores ts
    JOIN profiles p ON p.id = ts.user_id
    ORDER BY ts.total_score DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 7. INITIAL CALCULATION FOR ALL USERS
-- ============================================
-- Run this once to populate scores for existing users
DO $$
DECLARE
    v_user RECORD;
BEGIN
    FOR v_user IN SELECT id FROM auth.users LOOP
        PERFORM update_trust_score(v_user.id);
    END LOOP;
END $$;

-- ============================================
-- MIGRATION COMPLETE
-- ============================================
-- Trust Score system is now fully operational!
