-- ============================================
-- Admin Matches Policy - DÜZELTME
-- ============================================
-- Eski policy'yi sil
DROP POLICY IF EXISTS "Admin can view all matches" ON matches;

-- Yeni doğru policy: Admin tüm eşleşmeleri görebilsin
CREATE POLICY "Admin can view all matches"
    ON matches FOR SELECT
    USING (
        auth.uid() IS NOT NULL AND
        (SELECT email FROM auth.users WHERE id = auth.uid()) = 'caner@brokerlink.com'
    );

-- Kontrol
SELECT COUNT(*) FROM matches;
