#!/bin/bash

[ "$(id -u)" -ne 0 ] && [ "$(id -un)" != "ds" ] && { echo "Root or ds privileges required"; exit 1; }

DIR="/var/www/M4_DS_PREFIX"
ADMINPANEL="$DIR/server/AdminPanel/server/adminpanel"

[ -x "$ADMINPANEL" ] || { echo "AdminPanel CLI not found: $ADMINPANEL"; exit 1; }

export NODE_ENV="${NODE_ENV:-production-linux}"
export NODE_CONFIG_DIR="${NODE_CONFIG_DIR:-/etc/M4_DS_PREFIX}"
export NODE_DISABLE_COLORS="${NODE_DISABLE_COLORS:-1}"

cd "$DIR/server/AdminPanel" || { echo "AdminPanel workdir not found: $DIR/server/AdminPanel"; exit 1; }

if [ "$(id -u)" -eq 0 ]; then
	command -v runuser >/dev/null 2>&1 || { echo "runuser is required when running as root"; exit 1; }
	exec runuser -u ds -- "$ADMINPANEL" --cli "$@"
fi

exec "$ADMINPANEL" --cli "$@"
