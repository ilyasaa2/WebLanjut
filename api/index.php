<?php

// 1. Fix Vercel routing: Ensure SCRIPT_NAME is /index.php so /api routes match correctly
$_SERVER['SCRIPT_NAME'] = '/index.php';

// 2. Prepare writable /tmp SQLite database
$tmpDir = '/tmp';
$dbPath = $tmpDir . '/database.sqlite';

if (!file_exists($dbPath) || filesize($dbPath) === 0) {
    $sourceDb = __DIR__ . '/../database/database.sqlite';
    if (file_exists($sourceDb) && filesize($sourceDb) > 0) {
        copy($sourceDb, $dbPath);
    } else {
        touch($dbPath);
    }
}

putenv("DB_CONNECTION=sqlite");
$_ENV['DB_CONNECTION'] = 'sqlite';
putenv("DB_DATABASE={$dbPath}");
$_ENV['DB_DATABASE'] = $dbPath;

// 3. Ensure writable storage paths in serverless environment
$storageDirs = [
    '/tmp/storage',
    '/tmp/storage/framework',
    '/tmp/storage/framework/views',
    '/tmp/storage/framework/cache',
    '/tmp/storage/framework/sessions',
    '/tmp/storage/logs'
];

foreach ($storageDirs as $dir) {
    if (!is_dir($dir)) {
        mkdir($dir, 0755, true);
    }
}

putenv("VIEW_COMPILED_PATH=/tmp/storage/framework/views");
$_ENV['VIEW_COMPILED_PATH'] = '/tmp/storage/framework/views';

require __DIR__ . '/../public/index.php';
