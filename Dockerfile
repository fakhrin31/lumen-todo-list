# Gunakan image PHP FPM berbasis Debian "Bullseye", yang lebih stabil dan terbaru.
FROM php:8.1-fpm-bullseye

# Atur working directory di dalam container.
WORKDIR /var/www/html

# Install dependensi sistem yang diperlukan:
# - git: untuk menginstal dependensi Composer
# - libpq-dev: untuk driver PostgreSQL
# - zip, unzip: untuk Composer
# - libzip-dev: diperlukan oleh ekstensi zip
# - libxml2-dev: diperlukan untuk ekstensi xml
# - libpng-dev: diperlukan untuk ekstensi gd
# - libjpeg62-turbo-dev: pengganti untuk libjpeg-turbo-dev di Bullseye
# - libwebp-dev: diperlukan untuk ekstensi gd
# - libfreetype-dev: diperlukan untuk ekstensi gd
# - libonig-dev: diperlukan oleh ekstensi mbstring
RUN apt-get update && apt-get install -y \
    git \
    libpq-dev \
    zip \
    unzip \
    libzip-dev \
    libxml2-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libwebp-dev \
    libfreetype-dev \
    libonig-dev \
    && rm -rf /var/lib/apt/lists/*

# Instal ekstensi PHP yang diperlukan oleh Laravel dan PostgreSQL.
RUN docker-php-ext-install pdo_pgsql pgsql

# Instal ekstensi bcmath
RUN docker-php-ext-install bcmath

# Instal ekstensi ctype
RUN docker-php-ext-install ctype

# Instal ekstensi fileinfo
RUN docker-php-ext-install fileinfo

# Instal ekstensi json
RUN docker-php-ext-install json

# Instal ekstensi mbstring
RUN docker-php-ext-install mbstring

# Instal ekstensi openssl
RUN docker-php-ext-install openssl

# Instal ekstensi tokenizer
RUN docker-php-ext-install tokenizer

# Instal ekstensi xml
RUN docker-php-ext-install xml

# Instal Composer secara global di dalam container.
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Salin semua file dari proyek lokal ke working directory container.
COPY . .

# Hapus file .env karena kredensial akan disediakan oleh Render sebagai environment variables.
RUN rm -f .env

# Jalankan Composer untuk menginstal semua dependensi PHP.
RUN composer install --no-dev --optimize-autoloader

# Izinkan web server menulis ke folder storage
RUN chmod -R 775 storage

# Ekspos port 8000 yang akan digunakan oleh server PHP.
EXPOSE 8000

# Tentukan perintah untuk menjalankan server PHP bawaan.
CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]
