-- ============================================
-- Performance Indexes & Security Check
-- ============================================

-- 1. Eşleşme Sorguları İçin İndeksler
-- Bekleyen eşleşmeleri hızlı sorgulamak için
CREATE INDEX IF NOT EXISTS idx_matches_status ON matches(status);
CREATE INDEX IF NOT EXISTS idx_matches_demand_id ON matches(demand_id);
CREATE INDEX IF NOT EXISTS idx_matches_portfolio_id ON matches(portfolio_id);

-- 2. Network Sorguları İçin İndeksler
-- Tarihe göre sıralama ve user_id ile filtreleme için composite indexler
CREATE INDEX IF NOT EXISTS idx_portfolios_user_created ON portfolios(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_demands_user_created ON demands(user_id, created_at DESC);

-- 3. RLS Kontrolü
-- Row Level Security (Satır Bazlı Güvenlik) açık olduğundan emin olalım
ALTER TABLE IF EXISTS portfolios ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS demands ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS connection_requests ENABLE ROW LEVEL SECURITY;

-- 4. Temizlik (Opsiyonel)
-- Eski/Hatalı verileri temizlemek için script (Production öncesi)
-- DELETE FROM matches WHERE demand_id IS NULL OR portfolio_id IS NULL;
