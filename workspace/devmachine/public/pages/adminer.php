<?php

chdir('../../vendor/vrana/adminer');

$db_adminer_file = array_values(array_filter(scandir('.', SCANDIR_SORT_DESCENDING), function ($file) {
    $name = 'adminer';
    return $name === substr($file, 0, strlen($name));
}))[0];

include $db_adminer_file;