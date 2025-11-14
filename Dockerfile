# Usa una imagen base de PHP con Apache
FROM php:7.4-apache

# Argumentos definidos en docker-compose.yml
ARG container_project_path
ARG uid
ARG user

# 1. Instalar dependencias del sistema y extensiones de PHP necesarias para Laravel/Krayin
RUN apt-get update && apt-get install -y \
    git \
    libzip-dev \
    unzip \
    libpng-dev \
    libxml2-dev \
    libonig-dev \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Instalar extensiones de PHP
RUN docker-php-ext-install pdo_mysql zip gd mbstring exif pcntl

# 2. Instalar Composer (gestor de dependencias de PHP)
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# 3. Configurar el servidor web (Apache)
RUN a2enmod rewrite

# 4. Crear un usuario no root para seguridad (usando el UID y el usuario del compose)
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Establecer la carpeta de trabajo
WORKDIR ${container_project_path}

# 5. Configurar el acceso para el usuario del sistema
USER $user

# Comando por defecto para iniciar Apache
CMD ["apache2-foreground"]
