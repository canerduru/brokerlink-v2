-- ============================================
-- Auto-Match Generation Triggers
-- ============================================
-- Bu triggerlar yeni bir talep veya portföy eklendiğinde
-- otomatik olarak eşleşme algoritmasını tetikler.

-- 1. Trigger Fonksiyonu
CREATE OR REPLACE FUNCTION auto_generate_matches()
RETURNS TRIGGER AS $$
BEGIN
    -- Frontend'in dinleyebilmesi için pg_notify kullanıyoruz.
    -- Payload olarak yeni eklenen kaydın ID'sini gönderiyoruz.
    PERFORM pg_notify('match_generation', NEW.id::text);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Demands Trigger
DROP TRIGGER IF EXISTS trigger_demand_insert ON demands;
CREATE TRIGGER trigger_demand_insert
AFTER INSERT ON demands
FOR EACH ROW
EXECUTE FUNCTION auto_generate_matches();

-- 3. Portfolios Trigger
DROP TRIGGER IF EXISTS trigger_portfolio_insert ON portfolios;
CREATE TRIGGER trigger_portfolio_insert
AFTER INSERT ON portfolios
FOR EACH ROW
EXECUTE FUNCTION auto_generate_matches();

-- ============================================
-- Nasıl Çalışır?
-- 1. Tabloya yeni kayıt eklenir (INSERT)
-- 2. Trigger çalışır ve 'match_generation' kanalına bildirim gönderir
-- 3. Frontend (Realtime) bu bildirimi alır ve generateMatches() çalıştırır
-- ============================================
