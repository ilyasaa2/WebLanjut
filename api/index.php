<?php

// Di lingkungan Vercel serverless, hanya direktori /tmp yang memiliki izin tulis (writable).
$tmpDir = '/tmp';
$dbPath = $tmpDir . '/database.sqlite';

if (!file_exists($dbPath)) {
    $sourceDb = __DIR__ . '/../database/database.sqlite';
    if (file_exists($sourceDb)) {
        copy($sourceDb, $dbPath);
    } else {
        touch($dbPath);
    }
}

putenv("DB_DATABASE={$dbPath}");
$_ENV['DB_DATABASE'] = $dbPath;
putenv("VIEW_COMPILED_PATH=/tmp/views");
$_ENV['VIEW_COMPILED_PATH'] = '/tmp/views';

if (!is_dir('/tmp/views')) {
    mkdir('/tmp/views', 0755, true);
}

require __DIR__ . '/../public/index.php';
