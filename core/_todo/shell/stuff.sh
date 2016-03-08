#!/usr/bin/env bash

#             bashrc = $yaml_config['devmachine']['bashrc']
#             bashrc = "cd /opt/devmachine"
#             node.vm.provision "bashrc", type: "shell", keep_color: true, run: "always", inline: %~
#                 touch \~/.bash_profile
#                 (grep -q -F "#{bashrc}" "\~/.bash_profile" || echo -e "\n#{bashrc}" >> "\~/.bash_profile")
#             ~


chown www-data:www-data /app -R
tail -F /var/log/apache2/* &


# RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
# RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
#    sed -i "s/variables_order.*/variables_order = \"EGPCS\"/g" /etc/php5/apache2/php.ini



# Add ServerName to apache2
SERVERNAME=`sed -n 's/.*\(ServerName .*\)/\1/p' /vagrant/config/apache2.conf`
if ! grep -Fq "$SERVERNAME" /etc/apache2/httpd.conf ; then
  echo $SERVERNAME > /etc/apache2/httpd.conf
  echo "ServerName written to /etc/apache2/httpd.conf: $SERVERNAME"
fi

# Externalize mysql
if test -d "/etc/mysql"; then
    if test ! -d "/shared/mysql"; then
        sudo mv /etc/mysql /shared
    fi
    sudo ln -s /shared/mysql /etc/mysql
fi

# Install phpmyadmin
if test ! -d "/etc/phpmyadmin/"; then
    # Avoid interaction # check debconf-get-selections | grep phpmyadmin
    echo 'phpmyadmin phpmyadmin/dbconfig-install boolean true' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/app-password-confirm password root' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/mysql/admin-pass password root' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/mysql/app-pass password root' | debconf-set-selections
    echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections
    # Ignore the post install questions
    export DEBIAN_FRONTEND=noninteractive
    # Install
    apt-get -y install phpmyadmin
fi

# Check installed packages
export PACKAGES=`dpkg-query -W -f' |- ${Package} ${Status} -| '`
installed()
{
  if [[ $PACKAGES = *\|\-\ $1\ install\ ok\ installed\ \-\|* ]]; then
    return 0 # is installed
  else
    return 1 # is not installed
  fi
}
export -f installed

# Create ssh keys
if test ! -f "${VAGRANT_CORE_FOLDER}/files/dot/ssh/id_rsa"; then
    echo "Creating new SSH key at ${VAGRANT_CORE_FOLDER}/files/dot/ssh/id_rsa"
    ssh-keygen -f "${VAGRANT_CORE_FOLDER}/files/dot/ssh/id_rsa" -P ""
fi
echo "Adding generated key to /root/.ssh/authorized_keys"
mkdir -p /root/.ssh
cat "${VAGRANT_CORE_FOLDER}/files/dot/ssh/id_rsa.pub" > "/root/.ssh/authorized_keys"
chmod 600 "/root/.ssh/authorized_keys"
if [ "${VAGRANT_SSH_USERNAME}" != 'root' ]; then
    VAGRANT_SSH_FOLDER="/home/${VAGRANT_SSH_USERNAME}/.ssh";

    echo "Adding generated key to ${VAGRANT_SSH_FOLDER}/authorized_keys"
    cat "${VAGRANT_CORE_FOLDER}/files/dot/ssh/id_rsa.pub" > "${VAGRANT_SSH_FOLDER}/authorized_keys"
    chown "${VAGRANT_SSH_USERNAME}" "${VAGRANT_SSH_FOLDER}/authorized_keys"
    chgrp "${VAGRANT_SSH_USERNAME}" "${VAGRANT_SSH_FOLDER}/authorized_keys"
    chmod 600 "${VAGRANT_SSH_FOLDER}/authorized_keys"
fi
passwd -d vagrant >/dev/null

# ====== ====== ====== ====== ====== ======
# XDebug - http://www.mailbeyond.com/phpstorm-vagrant-install-xdebug-php | https://gist.github.com/maurotdo/5635445 | http://ubuntuforums.org/showthread.php?t=525257 | http://tiger-fish.com/blog/drupal-debugging-code-inside-vagrant-instance-using-xdebug
# ====== ====== ====== ====== ====== ======

# Install
apt-get -y php5-xdebug

# Update xdebug config with actual path
xdebug=`find / -name 'xdebug.so' 2> /dev/null`
sed -i $'s|zend_extension=.*|zend_extension="'$xdebug'"|' /vagrant/config/xdebug.ini

# Extend php.ini with xdebug config
xdebug_ini=`cat /vagrant/vagrant/xdebug.ini`
prefix='; Added by vagrant bootstrap - begin'
suffix='; Added by vagrant bootstrap - end'
if ! grep -Fxq "$xdebug_ini" /etc/php5/apache2/php.ini ; then
  # Integrate
  echo "Integrate Xdebug."

  # Make a backup
  cp /etc/php5/apache2/php.ini /etc/php5/apache2/php.ini.$NOW.bak

  # Remove old settings
  sed -i "/$prefix/,/$suffix/ d" /etc/php5/apache2/php.ini

  # Add new settings
  echo "$prefix" >> /etc/php5/apache2/php.ini
  echo "$xdebug_ini" >> /etc/php5/apache2/php.ini
  echo "$suffix" >> /etc/php5/apache2/php.ini

  # Restart apache
  sudo service apache2 restart
else
  echo "Xdebug integrated."
fi

# ====== ====== ====== ====== ====== ======
# Log - http://misc.flogisoft.com/bash/tip_colors_and_formatting
# ====== ====== ====== ====== ====== ======

VAGRANT_LOG_FILE=$(bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd )/get-config.sh" "VAGRANT_LOG_FILE")

# Function
log()
{
    DATE=$(date +"%d/%m/%Y")
    TIME=$(date +"%H:%M:%S")
    if test -n "${VAGRANT_LOG_FILE+1}"; then
        if test ! -f "${VAGRANT_LOG_FILE}"; then
            if test ! -d "$(dirname "${VAGRANT_LOG_FILE}")"; then
                mkdir -p "$(dirname "${VAGRANT_LOG_FILE}")"
            fi
            touch "${VAGRANT_LOG_FILE}"
        fi
        if ! grep -q "\-\-\- ${DATE} \-\-\-" "${VAGRANT_LOG_FILE}"; then
            echo "--- ${DATE} ---" >> "${VAGRANT_LOG_FILE}" # edit this, to only write this once per rundown, but also always one time!
        fi
        echo -e "${1}" | sed "s/^/$(echo -e "$TIME | ${4}" | sed -e 's/[\/&]/\\&/g')/" >> "${VAGRANT_LOG_FILE}"
    fi
    echo -e "${1}" | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g' | sed "s/^/$(echo -e "\e[2m$TIME | \e[0m${2}${4}" | sed -e 's/[\/&]/\\&/g')/" | sed "s/$/$(echo -e "${3}" | sed -e 's/[\/&]/\\&/g')/"
}

# ====== ====== ====== ====== ====== ======
# SSL - https://help.ubuntu.com/community/OpenSSL
# ====== ====== ====== ====== ====== ======

# Install
if ! which openssl &> /dev/null; then
    apt-get update
    apt-get -y install openssl libssl-dev
fi

# Report
if which openssl &> /dev/null; then
    OPENSSL_VERSION=$(openssl version | sed 's/^[^0-9]* //g')
    echo -e "\e[92m- openssl ${OPENSSL_VERSION}\e[0m"
else
    echo -e "\e[91m- openssl not found\e[0m"
fi

# ====== ====== ====== ====== ====== ======
# php.ini
# ====== ====== ====== ====== ====== ======

; Make sure PHP is as verbose as possible
display_startup_errors = true
display_errors = true
error_reporting = -1
error_log = syslog
report_memleaks = true

; XDebug settings
xdebug.default_enable = 1
xdebug.remote_autostart = 0
xdebug.remote_connect_back = 1
xdebug.remote_enable = 1
xdebug.remote_handler = "dbgp"
xdebug.remote_port = 9000

; XDebug output settings
xdebug.cli_color = true
xdebug.overload_var_dump = 128
xdebug.var_display_max_children = 128
xdebug.var_display_max_depth = 3
xdebug.var_display_max_data = 5