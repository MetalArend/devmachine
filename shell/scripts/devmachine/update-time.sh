#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Network Time Protocol - http://www.debian-administration.org/article/25/Keeping_your_clock_current_automatically.
# ====== ====== ====== ====== ====== ======

# Set timezone
cp /usr/share/zoneinfo/Europe/Brussels /etc/localtime

# Update time
ntpdate pool.ntp.org