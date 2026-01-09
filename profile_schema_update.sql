-- ============================================
-- Broker Profile & Networking Schema Update
-- ============================================
-- Bu script mevcut verileri bozmadan profil özelliklerini ekler.
-- Güvenli: IF NOT EXISTS kullanır, birden fazla çalıştırılabilir.

-- 1. PROFILES Tablosu Güncellemesi
-- ============================================
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS avatar_url TEXT,
ADD COLUMN IF NOT EXISTS cover_url TEXT,
ADD COLUMN IF NOT EXISTS title TEXT,
ADD COLUMN IF NOT EXISTS company TEXT,
ADD COLUMN IF NOT EXISTS phone TEXT,
ADD COLUMN IF NOT EXISTS bio TEXT,
ADD COLUMN IF NOT EXISTS ttyb_number TEXT, -- GİZLİ (Sadmin/sistem görür)
ADD COLUMN IF NOT EXISTS ttyb_verified BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS social_links JSONB DEFAULT '{}',
ADD COLUMN IF NOT EXISTS service_areas JSONB DEFAULT '[]',
ADD COLUMN IF NOT EXISTS specialties TEXT[] DEFAULT '{}';

-- 2. NETWORK CONNECTIONS Tablosu (YENİ)
-- ============================================
CREATE TABLE IF NOT EXISTS network_connections (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    requester_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    receiver_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'pending', -- pending, accepted, rejected
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(requester_id, receiver_id)
);

-- 3. İndeksler (Performans için)
-- ============================================
CREATE INDEX IF NOT EXISTS idx_connections_requester ON network_connections(requester_id);
CREATE INDEX IF NOT EXISTS idx_connections_receiver ON network_connections(receiver_id);
CREATE INDEX IF NOT EXISTS idx_connections_status ON network_connections(status);

-- 4. Row Level Security (RLS) Politikaları
-- ============================================
-- Profil bilgilerini herkes okuyabilir (public view)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON profiles;
CREATE POLICY "Public profiles are viewable by everyone" 
ON profiles FOR SELECT 
USING (true);

DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile" 
ON profiles FOR UPDATE 
USING (auth.uid() = id);

-- Network bağlantıları sadece ilgili kullanıcılar görebilir
ALTER TABLE network_connections ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their connections" ON network_connections;
CREATE POLICY "Users can view their connections" 
ON network_connections FOR SELECT 
USING (auth.uid() = requester_id OR auth.uid() = receiver_id);

DROP POLICY IF EXISTS "Users can create connections" ON network_connections;
CREATE POLICY "Users can create connections" 
ON network_connections FOR INSERT 
WITH CHECK (auth.uid() = requester_id);

DROP POLICY IF EXISTS "Users can update their connections" ON network_connections;
CREATE POLICY "Users can update their connections" 
ON network_connections FOR UPDATE 
USING (auth.uid() = requester_id OR auth.uid() = receiver_id);

-- ============================================
-- Tamamlandı!
-- ============================================
-- Sonraki Adım: Supabase Table Editor'da doğrulama yapın.
