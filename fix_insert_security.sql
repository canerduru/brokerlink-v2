-- ============================================
-- GÜVENLİK GÜNCELLEMESİ: KİMLİK DOĞRULAMALI INSERT
-- ============================================
-- Bu script, kullanıcıların yalnızca kendi auth.uid() kimlikleriyle 
-- eşleşen user_id verilerini ekleyebilmesini zorunlu kılar.
-- Kimse başkasının yerine (sahte user_id ile) kayıt ekleyemez.

-- 1. DEMANDS (Talepler)
DROP POLICY IF EXISTS "Users can only insert their own demands" ON demands;
CREATE POLICY "Users can only insert their own demands" 
ON demands FOR INSERT 
TO authenticated 
WITH CHECK (user_id = auth.uid());

-- 2. PORTFOLIOS (Portföyler)
DROP POLICY IF EXISTS "Users can only insert their own portfolios" ON portfolios;
CREATE POLICY "Users can only insert their own portfolios" 
ON portfolios FOR INSERT 
TO authenticated 
WITH CHECK (user_id = auth.uid());

-- 3. MESSAGES (Mesajlar)
DROP POLICY IF EXISTS "Users can only insert their own messages" ON messages;
CREATE POLICY "Users can only insert their own messages" 
ON messages FOR INSERT 
TO authenticated 
WITH CHECK (sender_id = auth.uid());

-- 4. NETWORK CONNECTIONS (Ağ Bağlantıları)
DROP POLICY IF EXISTS "Users can only insert their own connections" ON network_connections;
CREATE POLICY "Users can only insert their own connections" 
ON network_connections FOR INSERT 
TO authenticated 
WITH CHECK (requester_id = auth.uid() OR responder_id = auth.uid());


-- 5. MATCHES (Eşleşmeler - Kullanıcı kendi adına match atabiliyorsa)
-- Zaten auto_match_triggers.sql veya manuel JS tarafından tetikleniyor.
DROP POLICY IF EXISTS "Users can only insert matches related to them" ON matches;
CREATE POLICY "Users can only insert matches related to them" 
ON matches FOR INSERT 
TO authenticated 
WITH CHECK (
    demand_id IN (SELECT id FROM demands WHERE user_id = auth.uid()) OR
    portfolio_id IN (SELECT id FROM portfolios WHERE user_id = auth.uid())
);

SELECT 'Güvenlik ilkeleri (Insert Validation) başarıyla uygulandı.' as Status;
