<?php
error_reporting(E_ALL);
ini_set('display_errors', true);

function getDockerVariable($alias, $variable)
{
    $key = strtoupper($alias) . '_PORT';
    $port = substr(getenv($key), strrpos(getenv($key), ':') + 1);
    return getenv($key . '_' . $port . '_' . strtoupper($variable));
}

$db_port = getDockerVariable('db', 'tcp_port');
$db_server = getDockerVariable('db', 'tcp_addr');
$db_database = getenv('DB_ENV_MYSQL_DATABASE');
$db_user = getenv('DB_ENV_MYSQL_USER');
$db_password = getenv('DB_ENV_MYSQL_PASSWORD');
$db_adminer_file = array_values(array_filter(scandir('./pages', SCANDIR_SORT_DESCENDING), function ($file) {
    $name = 'adminer';
    return $name === substr($file, 0, strlen($name));
}))[0];
$db_adminer_url = 'pages/' . $db_adminer_file . '?server=' . $db_server . '&username=' . $db_user . '&db=' . $db_database;
$dsn = null;
$pdo = null;
$version = null;
$user = null;
$error = '';
if (!empty($db_server)):
    try {
        $dsn = 'mysql:host=' . $db_server . ';dbname=mysql';
        $pdo = new PDO($dsn, 'root', getenv('DB_ENV_MYSQL_ROOT_PASSWORD'));
        if (!empty($pdo)):
            $versionStmt = $pdo->query('SELECT VERSION() AS Version');
            $version = $versionStmt->fetchObject()->Version;
            $userStmt = $pdo->query('SELECT Host, User FROM user WHERE user="' . $db_user . '"');
            $user = $userStmt->fetchObject();
        endif;
    } catch (\Exception $exception) {
        $error = $exception->getMessage();
    }
endif;
?>
<!doctype html>
<html>
<head>
    <title>Docker</title>
    <link type="text/css" rel="stylesheet" href="assets/bootstrap-3.3.5/css/bootstrap.min.css"/>
</head>
<body>
<nav class="navbar navbar-inverse navbar-static-top">
    <div class="container-fluid">
        <div class="navbar-header">
            <a class="navbar-brand" onclick="$('a[data-toggle=tab][href=#workspaces]').trigger('click'); return false;">
                DevMachine
            </a>
        </div>
        <ul class="nav navbar-nav" role="tablist">
            <li>
                <a href="#workspaces" role="tab" data-toggle="tab">
                    <span class="glyphicon glyphicon-home" style="width: 14px;"></span>
                    workspaces
                </a>
            </li>
            <li>
                <a href="#apache" role="tab" data-toggle="tab">
                    <span class="glyphicon glyphicon-list-alt" style="width: 14px;"></span>
                    apache
                </a>
            </li>
            <li>
                <a href="#php" role="tab" data-toggle="tab">
                    <span class="glyphicon glyphicon-info-sign" style="width: 14px;"></span>
                    phpinfo
                </a>
            </li>
            <li>
                <a href="#fpm" role="tab" data-toggle="tab">
                    <span class="glyphicon glyphicon-dashboard" style="width: 14px;"></span>
                    fpm status
                </a>
            </li>
            <li>
                <a href="<?php echo $db_adminer_url; ?>" target="_blank">
                    <span class="glyphicon glyphicon-compressed" style="width: 14px;"></span>
                    adminer
                </a>
            </li>
        </ul>
        <div class="navbar-text pull-right">
            &copy; 2014-<?php echo date('Y'); ?>
            <a href="https://twitter.com/MetalArend" class="navbar-link">MetalArend</a>
        </div>
    </div>
</nav>
<div class="container-fluid">
    <div class="tab-content">
        <div id="workspaces" class="tab-pane">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h2 class="panel-title">Environment</h2>
                </div>
                <div class="panel-body">
                    <ul>
                        <li>
                            <?php echo str_replace('/', ' ', $_SERVER['SERVER_SOFTWARE']); ?>
                        </li>
                        <li>
                            <?php if (empty($db_server)): ?>
                                Database server not found.
                            <?php elseif (empty($pdo)): ?>
                                <?php if (!empty($error)): ?>
                                    <?php echo $error; ?>
                                <?php else : ?>
                                    Database connection not found.
                                <?php endif; ?>
                            <?php elseif (!empty($version) && !empty($user)): ?>
                                MySQL <?php echo $version; ?> on <?php echo $db_server; ?>:<?php echo $db_port; ?>
                                // '<?php echo $user->User; ?>'@'<?php echo $user->Host; ?>' IDENTIFIED BY '<?php echo $db_password ?>'
                            <?php endif; ?>
                        </li>
                        <li>
                            PHP <?php echo phpversion(); ?>
                            on <?php echo $_SERVER['SERVER_ADDR']; ?>:<?php echo $_SERVER['SERVER_PORT']; ?>
                        </li>
                    </ul>
                </div>
            </div>
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h2 class="panel-title">Workspaces</h2>
                </div>
                <div class="panel-body">
                    <ul>
                        <?php
                        $dir = realpath(rtrim(dirname(dirname(__FILE__)), '/') . '/../');
                        if ($handle = opendir($dir)) {
                            while (false !== ($entry = readdir($handle))) {
                                if (!is_dir($dir . '/' . $entry) || in_array($entry,
                                        array('.', '..', 'devmachine')) || '.' === substr($entry, 0, 1)
                                ) {
                                    continue;
                                }
                                echo '<li><!--<a href="../' . $entry . '">-->' . $entry . '<!--</a>--></li>';
                            }
                            closedir($handle);
                        }
                        ?>
                    </ul>
                </div>
            </div>
        </div>
        <div id="apache" class="tab-pane">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h2 class="panel-title">Apache</h2>
                </div>
                <div class="panel-body">
                    <iframe src="pages/apache.php" style="width:100%; border:0;"></iframe>
                </div>
            </div>
        </div>
        <div id="php" class="tab-pane">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h2 class="panel-title">PHP info</h2>
                </div>
                <div class="panel-body">
                    <iframe src="pages/phpinfo.php" style="width:100%; border:0;"></iframe>
                </div>
            </div>
        </div>
        <div id="fpm" class="tab-pane">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h2 class="panel-title">FPM status</h2>
                </div>
                <div class="panel-body">
                    <iframe src="/fpm-status" style="width:100%; border:0;"></iframe>
                </div>
            </div>
        </div>
    </div>
</div>
<script type="text/javascript" src="assets/jquery-1.11.3/jquery.min.js"></script>
<script type="text/javascript" src="assets/bootstrap-3.3.5/js/bootstrap.min.js"></script>
<script type="text/javascript">
    function loadFrame(iframe) {
        var $iframe = $(iframe);
        if (1 === $iframe.length) {
            // Avoid flicker when reloading, by cloning into a new iframe instead of reloading the src
            var $iframeReloaded = $iframe.clone(true, true);
            $iframeReloaded.one('load', (function ($iframe, $iframeReloaded) {
                return function () {
                    $iframeReloaded.show().attr('height', '0').attr('height', ($iframeReloaded.get(0).contentWindow.document.body.scrollHeight * 1.001) + 'px');
                    $iframe.remove();
                };
            }($iframe, $iframeReloaded)));
            $iframeReloaded.hide().insertBefore($iframe);
        }
    }
    $(document).ready(function () {
        $('iframe').hide();
        var $tabs = $('a[data-toggle="tab"]');
        $tabs.on('click', function (event) {
            var id = $(event.target).attr('href').replace('#', '');
            window.location.hash = id;
            loadFrame($('#' + id).find('iframe'));
        });
        if ('' === window.location.hash) {
            $tabs.first().trigger('click');
        } else {
            $tabs.filter('[href="#' + window.location.hash.replace('#', '') + '"]').trigger('click');
        }
    });
</script>
</body>
</html>