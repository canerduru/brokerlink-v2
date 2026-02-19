-- ============================================
-- Fix: Add DELETE RLS policy for network_connections
-- ============================================
-- Sorun: network_connections tablosunda DELETE politikası yok.
-- Bu yüzden rejectConnectionRequest() çağrısı sessizce başarısız oluyor.

-- Delete existing policy if any
DROP POLICY IF EXISTS "Users can delete their connections" ON network_connections;

-- Allow users to delete connections where they are either the requester or receiver
CREATE POLICY "Users can delete their connections"
ON network_connections FOR DELETE
USING (auth.uid() = requester_id OR auth.uid() = receiver_id);

-- Verify
SELECT 'DELETE policy for network_connections created!' as status;
