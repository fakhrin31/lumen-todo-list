# Stage 1: Build dependencies & Composer install
FROM php:8.1-fpm-bullseye AS builder

WORKDIR /var/www/html

# Install system dependencies (hanya untuk build)
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpq-dev \
    libzip-dev \
    libxml2-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libwebp-dev \
    libfreetype-dev \
    libonig-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_pgsql pgsql bcmath mbstring xml zip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Copy source code
COPY . .

# Remove local .env (Render pakai Environment Variables)
RUN rm -f .env

# Install PHP dependencies (hanya production)
RUN composer install --no-dev --optimize-autoloader --no-scripts --no-progress


# Stage 2: Final lightweight image
FROM php:8.1-fpm-bullseye

WORKDIR /var/www/html

# Install runtime system dependencies (lebih sedikit dari builder)
RUN apt-get update && apt-get install -y \
    libpq5 \
    libzip4 \
    libxml2 \
    libpng16-16 \
    libjpeg62-turbo \
    libwebp6 \
    libfreetype6 \
    libonig5 \
    && rm -rf /var/lib/apt/lists/*

# Copy PHP extensions from builder
COPY --from=builder /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=builder /usr/local/etc/php/conf.d /usr/local/etc/php/conf.d

# Copy project files & vendor
COPY --from=builder /var/www/html /var/www/html

# Set permissions
RUN chmod -R 775 storage bootstrap/cache

EXPOSE 8000

CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]
