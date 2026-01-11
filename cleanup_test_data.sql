-- ============================================
-- Production Data Cleanup Script
-- ============================================
-- ⚠️ WARNING: This script deletes ALL user generated content!
-- Execute only when ready for a fresh production start.

BEGIN;

-- 1. Truncate Tables (Cascade to remove related matches, etc)
TRUNCATE TABLE matches CASCADE;
TRUNCATE TABLE demands CASCADE;
TRUNCATE TABLE portfolios CASCADE;
TRUNCATE TABLE connection_requests CASCADE;
TRUNCATE TABLE connections CASCADE;
TRUNCATE TABLE messages CASCADE;
TRUNCATE TABLE conversations CASCADE;

-- 2. Optional: Reset Sequences (if IDs are integers, likely UUIDs so not needed but good practice for serials)
-- ALTER SEQUENCE demands_id_seq RESTART WITH 1;
-- ...

-- 3. Verify Clean State
SELECT count(*) as match_count FROM matches;
SELECT count(*) as demand_count FROM demands;
SELECT count(*) as portfolio_count FROM portfolios;

-- 4. Initial Seed Data (Optional - e.g., System User)
-- INSERT INTO profiles ...

COMMIT;
