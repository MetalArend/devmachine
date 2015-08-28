<?php

$envVariables = array(
    'APACHE_RUN_USER', 'APACHE_RUN_GROUP', 'APACHE_PID_FILE', 'APACHE_RUN_DIR',
    'APACHE_LOCK_DIR', 'APACHE_LOG_DIR', 'APACHE_SERVERADMIN', 'APACHE_SERVERNAME',
    'APACHE_HOST', 'APACHE_PORT', 'APACHE_DOCUMENTROOT'
);
$envPairs = array();
foreach ($envVariables as $variable) {
    $value = getenv($variable);
    if (!empty($value)) {
        $envPairs[$variable] = $value;
    }
}
if (!empty($envPairs)) {
    echo '<h2>Environment variables</h2>';
    foreach ($envPairs as $variable => $value) {
        echo $variable . ': ' . getenv($variable) . '<br />' . "\n";
    }
}

if (!empty($_SERVER)) {
    echo '<h2>Server variables</h2>';
    foreach ($_SERVER as $key => $value) {
        echo $key . ': ' . $value . '<br />' . "\n";
    }
}

if (is_callable('apache_request_headers')) {
    echo '<h2>Headers</h2>';

    $headers = apache_request_headers();
    foreach ($headers as $header => $value) {
        echo $header . ': ' . $value . '<br />' . "\n";
    }
}



