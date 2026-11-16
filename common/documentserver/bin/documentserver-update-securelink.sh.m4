#!/bin/sh

while [ "$1" != "" ]; do
	case $1 in

		-s | --secure_link_secret )
			if [ "$2" != "" ]; then
				SECURE_LINK_SECRET=$2
				shift
			fi
		;;

                -r | --restart )
                        if [ "$2" != "" ]; then
                                RESTART_CONDITION=$2
                                shift
                        fi
                ;;


		-? | -h | --help )
			echo "  Usage $0 [PARAMETER] [[PARAMETER], ...]"
			echo "    Parameters:"
			echo "      -s, --secure_link_secret               setting for secret string "
			echo "                                             (other users can see arguments; prefer"
			echo "                                             the SECURE_LINK_SECRET environment variable)"
			echo "      -r, --restart                          false: don't restart the services"
			echo "      -?, -h, --help                    this help"
			echo
			exit 0
		;;

	esac
	shift
done

NGINX_CONF=/etc/M4_DS_PREFIX/nginx/ds.conf
LOCAL_CONF=/etc/M4_DS_PREFIX/local.json
SECURE_LINK_SECRET=${SECURE_LINK_SECRET:-$(tr -dc A-Za-z0-9 </dev/urandom | head -c 20)}

# The secret goes to sed and json on stdin, not in their arguments: other
# users of the host can read the arguments of a running process. printf is a
# shell builtin, so it has no argument list of its own.
printf '%s\n' "s,\(set \+\$secure_link_secret\).*,\1 ${SECURE_LINK_SECRET};," \
	| sed -f /dev/stdin -i ${NGINX_CONF}

# --merge replaces the whole "storage" key with the object from stdin.
LOCAL_CONF_TMP=$(mktemp "${LOCAL_CONF}.XXXXXX") || exit 1
if { cat ${LOCAL_CONF}; printf '{"storage":{"fs":{"secretString":"%s"}}}\n' "${SECURE_LINK_SECRET}"; } \
	| /var/www/M4_DS_PREFIX/npm/json -q --merge > "${LOCAL_CONF_TMP}" && [ -s "${LOCAL_CONF_TMP}" ]; then
	cat "${LOCAL_CONF_TMP}" > ${LOCAL_CONF} && chown ds:ds $LOCAL_CONF
fi
rm -f "${LOCAL_CONF_TMP}"

if [ "$RESTART_CONDITION" != "false" ]; then
  if pgrep -x ""systemd"" >/dev/null; then
    systemctl restart ds-docservice
    systemctl restart ds-converter
    systemctl reload nginx
  elif pgrep -x ""supervisord"" >/dev/null; then
    supervisorctl restart ds:docservice
    supervisorctl restart ds:converter
    service nginx reload
  fi
fi
