<?php
error_reporting(E_ALL);
ini_set('display_errors', true);

$ip = reset(array_filter(array_merge(gethostbynamel(gethostname()), array(isset($_SERVER['HTTP_HOST']) ? strtok($_SERVER['HTTP_HOST'], ':') : '')), function ($ip) {
    return 0 === strpos($ip, "192.168.");
}));

$files = array_diff(scandir('.', SCANDIR_SORT_DESCENDING), array('.', '..', 'index.php'));

header('Location: ' . array_shift($files) . '?server=' . $ip . '&username=docker&db=mysql');
exit;