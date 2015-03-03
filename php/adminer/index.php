<?php
error_reporting(E_ALL);
ini_set('display_errors', true);

$files = array_diff(scandir('.', SCANDIR_SORT_DESCENDING), array('.', '..', 'index.php'));

header('Location: ' . array_shift($files) . '?server=192.168.10.10&username=docker&db=mysql');
exit;