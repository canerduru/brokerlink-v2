-- ============================================
-- Network Demands Kontrol Sorgusu
-- ============================================
-- Bu sorgu şu bilgileri gösterir:
-- 1. Ağınızdaki kişiler (Can Dur vs.)
-- 2. Bu kişilerin talepleri
-- 3. Hangi taleplerin "Ağ Talepleri" sekmesinde görüneceği

-- 1. Önce ağınızdaki kişileri görelim (accepted connections)
SELECT 
    'NETWORK CONNECTIONS' as info_type,
    nc.id as connection_id,
    nc.status,
    p.name as contact_name,
    p.email as contact_email,
    p.company as contact_company
FROM network_connections nc
JOIN profiles p ON (
    CASE 
        WHEN nc.requester_id = auth.uid() THEN nc.receiver_id = p.id
        WHEN nc.receiver_id = auth.uid() THEN nc.requester_id = p.id
    END
)
WHERE (nc.requester_id = auth.uid() OR nc.receiver_id = auth.uid())
ORDER BY nc.status, p.name;

-- 2. Şimdi bu kişilerin taleplerini görelim
SELECT 
    'DEMANDS FROM NETWORK' as info_type,
    d.id as demand_id,
    d.title,
    d.category,
    d.budget,
    d.district,
    d.created_at,
    p.name as broker_name,
    p.email as broker_email,
    d.status as demand_status
FROM demands d
JOIN profiles p ON d.user_id = p.id
WHERE d.user_id IN (
    -- Accepted connections only
    SELECT receiver_id FROM network_connections 
    WHERE requester_id = auth.uid() AND status = 'accepted'
    
    UNION
    
    SELECT requester_id FROM network_connections 
    WHERE receiver_id = auth.uid() AND status = 'accepted'
)
AND d.user_id != auth.uid()
ORDER BY d.created_at DESC;

-- 3. Can Dur'un taleplerini özel olarak kontrol edelim
SELECT 
    'CAN DUR DEMANDS' as info_type,
    d.id,
    d.title,
    d.category,
    d.budget,
    d.district,
    d.status,
    d.created_at
FROM demands d
JOIN profiles p ON d.user_id = p.id
WHERE p.name ILIKE '%Can%Dur%'
ORDER BY d.created_at DESC;
