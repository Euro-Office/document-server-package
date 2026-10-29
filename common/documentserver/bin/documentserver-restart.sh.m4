#!/bin/sh

# Restart the document service and converter.
# Called by the AdminPanel font-management API after font regeneration.

if pgrep -x "systemd" > /dev/null; then
    systemctl restart ds-docservice ds-converter
elif pgrep -x "supervisord" > /dev/null; then
    supervisorctl restart docservice converter
else
    echo "documentserver-restart.sh: no supported init found (systemd/supervisord)" >&2
    exit 1
fi
