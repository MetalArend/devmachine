<?php
error_reporting(E_ALL);
ini_set('display_errors', true);

function getDockerVariable($alias, $variable)
{
    $key = strtoupper($alias) . '_PORT';
    $port = substr(getenv($key), strrpos(getenv($key), ':') + 1);
    return getenv($key . '_' . $port . '_' . strtoupper($variable));
}

?>
<!doctype html>
<html>
<head>
    <title>Docker</title>
</head>
<body>
<p>
    <?php echo str_replace('/', ' ', $_SERVER['SERVER_SOFTWARE']); ?>
    <br/>

    PHP <?php echo phpversion(); ?>
    on <?php echo $_SERVER['SERVER_ADDR']; ?>:<?php echo $_SERVER['SERVER_PORT']; ?>
    <a href="phpinfo.php">&rarr;</a>
    <br/>
    <?php
    $db_port = getDockerVariable('db', 'tcp_port');
    $db_server = getDockerVariable('db', 'tcp_addr');
    $db_database = getenv('DB_ENV_MYSQL_DATABASE');
    $db_user = getenv('DB_ENV_MYSQL_USER');
    $db_password = getenv('DB_ENV_MYSQL_PASSWORD');
    $db_adminer_file = array_values(array_filter(scandir('.', SCANDIR_SORT_DESCENDING), function ($file) {
        $name = 'adminer';
        return $name === substr($file, 0, strlen($name));
    }))[0];
    $dsn = 'mysql:host=' . $db_server . ';dbname=mysql';
    $pdo = new PDO($dsn, 'root', getenv('DB_ENV_MYSQL_ROOT_PASSWORD'));
    ?>
    <?php if (empty($pdo)): ?>
        Database connection not found.
    <?php else: ?>
        <?php
        $versionStmt = $pdo->query('SELECT VERSION() AS Version');
        $version = $versionStmt->fetchObject()->Version;
        $userStmt = $pdo->query('SELECT Host, User FROM user WHERE user="' . $db_user . '"');
        $user = $userStmt->fetchObject();
        ?>
        MySQL <?php echo $version; ?> on <?php echo $db_server; ?>:<?php echo $db_port; ?>
        <a href="<?php echo $db_adminer_file . '?server=' . $db_server . '&username=' . $db_user . '&db=' . $db_database; ?>">&rarr;</a>
        <br/>'<?php echo $user->User; ?>'@'<?php echo $user->Host; ?>'
        IDENTIFIED BY '<?php echo $db_password ?>'
    <?php endif; ?>
</p>

<ul>
    <?php
    $dir = rtrim(dirname(dirname(__FILE__)), '/');
    if ($handle = opendir($dir)) {
        while (false !== ($entry = readdir($handle))) {
            if (!is_dir($dir . '/' . $entry) || in_array($entry, array('.', '..', 'devmachine')) || '.' === substr($entry, 0, 1)) {
                continue;
            }
            echo '<li><a href="../' . $entry . '">' . $entry . '</a></li>';
        }
        closedir($handle);
    }
    ?>
</ul>

<p>devmachine &copy; 2014 MetalArend</p>
</body>
</html>