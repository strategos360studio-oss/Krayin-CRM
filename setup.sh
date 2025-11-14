#!/bin/bash

# Este script debe ejecutarse DENTRO del contenedor 'krayin-php-apache'
# después de que los servicios se hayan levantado.

echo "Iniciando la instalación de KrayinCRM..."

# 1. Instalar dependencias de PHP (Composer)
composer install --no-dev --prefer-dist

# 2. Copiar el archivo de configuración de entorno
cp .env.example .env

# 3. Generar la clave de la aplicación Laravel
php artisan key:generate

# 4. Configurar el entorno (si tienes un archivo .env específico para Docker)
# Nota: La configuración de la BD se hace generalmente aquí
# Asegúrate de que las variables DB_HOST, DB_DATABASE, etc., apunten a krayin-mysql

# 5. Migrar la base de datos y hacer el seed (instalación)
# Se usa 'migrate:fresh --seed' para crear tablas e insertar datos iniciales
echo "Migrando la base de datos e insertando datos iniciales..."
php artisan migrate:fresh --seed --force

# 6. Configurar el almacenamiento
php artisan storage:link

# 7. Asignar permisos al almacenamiento y bootstrap/cache
# Esto es vital para el funcionamiento de Laravel.
echo "Ajustando permisos..."
chmod -R 775 storage bootstrap/cache

echo "¡KrayinCRM ha sido instalado con éxito!"

# Si la instalación es para producción, este script debe terminar
# y la aplicación debe estar lista para responder peticiones.
