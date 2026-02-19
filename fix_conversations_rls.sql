-- ============================================
-- Fix: conversations RLS politikası
-- Sorun: Alıcı (receiver) kendi conversation'larını göremez
-- Çünkü mevcut policy sadece user_id = auth.uid() kontrolü yapıyor
-- Bu düzeltme receiver_id'yi de kapsar
-- ============================================

-- Mevcut politikaları temizle
DROP POLICY IF EXISTS "Users can view their conversations" ON conversations;
DROP POLICY IF EXISTS "Users can create conversations" ON conversations;
DROP POLICY IF EXISTS "Users can update their conversations" ON conversations;

-- SELECT: Hem gönderen hem alıcı görebilir
CREATE POLICY "Users can view their conversations"
ON conversations FOR SELECT
USING (auth.uid() = user_id OR auth.uid() = receiver_id);

-- INSERT: Sadece gönderen oluşturabilir
CREATE POLICY "Users can create conversations"
ON conversations FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- UPDATE: Hem gönderen hem alıcı güncelleyebilir (last_message vs.)
CREATE POLICY "Users can update their conversations"
ON conversations FOR UPDATE
USING (auth.uid() = user_id OR auth.uid() = receiver_id);

-- Verify
SELECT 'Conversations RLS policies fixed!' as status;
