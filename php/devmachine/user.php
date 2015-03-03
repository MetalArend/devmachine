<?php
error_reporting(E_ALL);
ini_set('display_errors', true);
$dsn = 'mysql:host=' . $_SERVER['SERVER_NAME'] . ';dbname=mysql';
$pdo = new PDO($dsn, 'docker', 'docker');
echo '<p>Database connection' . ((!empty($pdo)) ? ' found' : ' not found') . '.</p>';
$versionStmt = $pdo->query('SELECT VERSION() AS version');
$userStmt = $pdo->query('SELECT User FROM user WHERE user="docker"');
echo '<p>IP ' . $_SERVER['SERVER_NAME'] . '</p>';
echo '<p>MySQL ' . $versionStmt->fetchObject()->version . '</p>';
echo '<p>User "' . $userStmt->fetchObject()->User . '"</p>';
