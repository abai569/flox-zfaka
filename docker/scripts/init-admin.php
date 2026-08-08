<?php

if ($argc !== 3) {
    fwrite(STDERR, "Usage: init-admin.php <email> <password>\n");
    exit(2);
}

$email = $argv[1];
$password = $argv[2];
$host = getenv('DB_HOST') ?: 'db';
$port = getenv('DB_PORT') ?: '3306';
$name = getenv('DB_NAME') ?: 'zfaka';
$user = getenv('DB_USER') ?: 'zfaka';
$dbPassword = getenv('DB_PASSWORD');

$pdo = new PDO(
    "mysql:host={$host};port={$port};dbname={$name};charset=utf8mb4",
    $user,
    $dbPassword,
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
);

$salt = substr(bin2hex(random_bytes(8)), 0, 6);
$hash = md5(md5(trim($password)) . $salt . 'onepeople');
$statement = $pdo->prepare('INSERT INTO t_admin_user (email, password, secret, updatetime) VALUES (?, ?, ?, 0)');
$statement->execute([$email, $hash, $salt]);
