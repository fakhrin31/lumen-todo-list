# Gunakan image PHP FPM dengan Alpine sebagai base, yang ringan dan cepat.
FROM php:8.1-fpm-alpine

# Atur working directory di dalam container.
WORKDIR /var/www/html

# Install dependensi sistem yang diperlukan oleh PHP ekstensi:
# - git: untuk menginstal dependensi Composer dari repositori Git
# - postgresql-dev: untuk menginstal ekstensi PHP PostgreSQL
# - zip dan unzip: untuk Composer
# - libzip-dev: diperlukan oleh ekstensi zip
# - libpng-dev: diperlukan untuk ekstensi gd
# - libjpeg-turbo-dev: diperlukan untuk ekstensi gd
# - libwebp-dev: diperlukan untuk ekstensi gd
# - freetype-dev: diperlukan untuk ekstensi gd
# - libxml2-dev: diperlukan untuk ekstensi xml
RUN apk add --no-cache git postgresql-dev zip unzip libzip-dev libpng-dev libjpeg-turbo-dev libwebp-dev freetype-dev libxml2-dev

# Instal semua ekstensi PHP yang diperlukan dalam satu perintah RUN.
RUN docker-php-ext-install pdo_pgsql pgsql \
    && docker-php-ext-install bcmath ctype fileinfo json mbstring openssl tokenizer xml

# Instal Composer secara global di dalam container.
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Salin semua file dari proyek lokal ke working directory container.
COPY . .

# Hapus file .env karena kredensial akan disediakan oleh Render sebagai environment variables.
RUN rm -f .env

# Jalankan Composer untuk menginstal semua dependensi PHP.
# --no-dev: untuk skip dependensi pengembangan
# --optimize-autoloader: untuk optimasi autoloader di lingkungan produksi
RUN composer install --no-dev --optimize-autoloader

# Izinkan web server menulis ke folder storage
RUN chmod -R 775 storage

# Ekspos port 8000 yang akan digunakan oleh server PHP.
EXPOSE 8000

# Tentukan perintah untuk menjalankan server PHP bawaan.
# -t public: menggunakan folder 'public' sebagai root dokumen
# 0.0.0.0:$PORT: membuat server dapat diakses secara eksternal melalui port yang diberikan oleh Render
CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]
