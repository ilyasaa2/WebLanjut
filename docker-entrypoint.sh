#!/bin/sh
set -e

# If SQLite is used and file does not exist, create it
if [ "$DB_CONNECTION" = "sqlite" ] || [ -z "$DB_CONNECTION" ]; then
    DB_PATH="${DB_DATABASE:-/var/www/html/database/database.sqlite}"
    if [ ! -f "$DB_PATH" ]; then
        echo "Creating SQLite database file at $DB_PATH..."
        mkdir -p "$(dirname "$DB_PATH")"
        touch "$DB_PATH"
        chown -R www-data:www-data "$(dirname "$DB_PATH")"
    fi
fi

# Cache configuration in production
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true

# Run database migrations on deployment startup
if [ "$RUN_MIGRATIONS" = "true" ] || [ -z "$RUN_MIGRATIONS" ]; then
    echo "Running database migrations..."
    php artisan migrate --force || true
    if [ "$RUN_SEED" = "true" ]; then
        echo "Running database seeds..."
        php artisan db:seed --force || true
    fi
fi

exec "$@"
