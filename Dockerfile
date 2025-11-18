FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    libicu-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libwebp-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd intl zip calendar

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
ARG container_project_path
WORKDIR ${container_project_path}

# Copy existing application directory contents
COPY ./workspace/workspace ${container_project_path}

# Fix git ownership issue
RUN git config --global --add safe.directory ${container_project_path}

# Copy existing application directory permissions
ARG uid
ARG user
RUN if [ "$user" != "www-data" ]; then \
        useradd -G www-data,root -u $uid -d /home/$user $user && \
        mkdir -p /home/$user/.composer && \
        chown -R $user:$user /home/$user; \
    fi

# Install dependencies
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Set permissions
RUN chown -R www-data:www-data ${container_project_path} \
    && chmod -R 775 ${container_project_path}/storage \
    && chmod -R 775 ${container_project_path}/bootstrap/cache

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Update Apache configuration to point to public directory
RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf

# Expose port 80
EXPOSE 80

CMD ["apache2-foreground"]
