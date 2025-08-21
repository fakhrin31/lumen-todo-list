# Gunakan image PHP FPM dengan Alpine sebagai base, yang ringan dan cepat.
FROM php:8.1-fpm-alpine

# Atur working directory di dalam container.
WORKDIR /var/www/html

# Install dependensi sistem yang diperlukan:
# - git: untuk menginstal dependensi Composer dari repositori Git
# - postgresql-dev: untuk menginstal ekstensi PHP PostgreSQL
# - zip dan unzip: untuk Composer
RUN apk add --no-cache git postgresql-dev zip unzip

# Instal ekstensi PHP yang diperlukan oleh Laravel dan PostgreSQL:
# - pdo_pgsql: driver PDO untuk PostgreSQL
# - pgsql: ekstensi PHP untuk PostgreSQL
# - bcmath, ctype, fileinfo, json, mbstring, openssl, tokenizer, xml: ekstensi standar Laravel
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
