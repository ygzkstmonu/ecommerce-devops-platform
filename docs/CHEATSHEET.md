# DevOps Cheat Sheet - Hızlı Hatırlatma

## 🐳 Docker Komutları

### Image İşlemleri

```bash
docker images                    # Image'ları listele
docker build -t isim:tag .      # Image build et
docker rmi image_id             # Image sil
Container İşlemleri
docker ps                       # Çalışan container'lar
docker ps -a                    # Tüm container'lar
docker run -d -p 5000:5000 image  # Container başlat
docker stop container_id        # Durdur
docker logs container_id        # Logları gör
docker exec -it container sh    # Container'a gir
Docker Compose
docker-compose up -d            # Başlat (detached)
docker-compose down             # Durdur ve sil
docker-compose ps               # Container'ları listele
docker-compose logs -f          # Logları izle
docker-compose build            # Image'ları yeniden build et

📦 Dockerfile Anatomisi

FROM node:18-alpine             # Base image
WORKDIR /app                    # Çalışma dizini
COPY package.json .             # Dependency dosyası
RUN npm install                 # Build-time komut
COPY . .                        # Uygulama kodu
EXPOSE 5000                     # Port bilgisi
CMD ["npm", "start"]            # Runtime komutu

🌐 Git Komutları

git status                      # Değişiklikleri gör
git branch                      # Branch'leri listele
git checkout -b feature/x       # Yeni branch
git add .                       # Tümünü stage et
git commit -m "message"         # Commit
git push origin branch          # Push
git checkout main               # Main'e geç
git pull origin main            # Güncelle

🔧 Proje Yapısı Hatırlatma

ecommerce-devops-platform/
├── backend/
│   ├── Dockerfile              # Backend container tarifi
│   ├── server.js               # Express API
│   └── package.json            # Dependencies
├── frontend/
│   ├── Dockerfile              # Frontend container tarifi
│   └── index.html              # UI
├── docker-compose.yml          # Tüm servisleri orkestre et
├── scripts/
│   └── backup.sh               # Backup script'i
└── README.md

💡 Önemli Konseptler

Port Mapping: -p 3000:80
3000: Host (bilgisayarınız)
80: Container içi
Volume: Data kalıcılığı
volumes:
  - ./data:/app/data
Network: Container'lar arası iletişim
networks:
  - app-network

🚨 Sık Karşılaşılan Sorunlar

Container sürekli restart oluyor
docker logs container_name      # Hata mesajını gör
Port zaten kullanımda
# Windows'ta portu kontrol et
netstat -ano | findstr :5000
Image build etmiyor
# Cache'siz build et
docker build --no-cache -t image:tag .

📅 1-2 HAFTA SONRA GERİ DÖNÜŞ PLANI
# 1. Projeyi aç
cd ~/ecommerce-devops-platform

# 2. Cheat sheet'i oku
cat docs/CHEATSHEET.md

# 3. Projeyi başlat
docker-compose up -d

# 4. "Hmm, şu kısım neydi?" diye düşünürseniz
git log --oneline          # Commit history'ye bakın
cat docs/CHEATSHEET.md     # Cheat sheet'e bakın