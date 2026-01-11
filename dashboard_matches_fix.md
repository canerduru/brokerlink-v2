# Dashboard "Son Eşleşmeler" Sorunu

## 🔴 Sorun:
Dashboard'daki "Son Eşleşmeler" bölümü boş görünüyor.

## 🔍 Neden:
`filteredMatches` → `matches` computed property'sini kullanıyor
`matches` → `matchesTab` değerine göre filtreliyor
Dashboard'da `matchesTab` değeri yok veya yanlış

## ✅ Çözüm Seçenekleri:

### Seçenek 1: Dashboard için ayrı computed property (ÖNERİLEN)
```javascript
get dashboardMatches() {
    // Tüm eşleşmeleri göster (pending + approved)
    const allMatches = [
        ...(this.demandMatches || []),
        ...(this.portfolioMatches || [])
    ];
    
    // Deduplication
    const matchMap = new Map();
    allMatches.forEach(m => {
        const key = `${m.demand_id}-${m.portfolio_id}`;
        if (!matchMap.has(key)) {
            matchMap.set(key, m);
        }
    });
    
    // En yeni 4 eşleşme
    return Array.from(matchMap.values())
        .sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
        .slice(0, 4);
}
```

Sonra HTML'de (satır 676):
```html
<template x-for="match in dashboardMatches" :key="match.id">
```

### Seçenek 2: matchesTab'ı başlangıçta ayarla
```javascript
matchesTab: 'demands', // Varsayılan değer
```

## 📋 Hangisini Uygulayalım?
1. **Seçenek 1** → Daha temiz, dashboard bağımsız çalışır
2. **Seçenek 2** → Daha hızlı, ama matchesTab'a bağımlı kalır

Önerim: **Seçenek 1** (daha sürdürülebilir)
