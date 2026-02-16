#!/usr/bin/make -f
# -*- makefile -*-

export DH_VERBOSE=1

%:
	dh $@

override_dh_strip_nondeterminism:
	dh_strip_nondeterminism --exclude=.png

override_dh_shlibdeps:
	dh_shlibdeps --no-act

override_dh_strip:
	dh_strip -Xdocservice -Xconverter -Xmetrics -Xadminpanel -Xexample -Xjson -Xcore.node

execute_after_dh_fixperms:
	chmod 0640 debian/M4_PACKAGE_NAME/etc/M4_DS_PREFIX/*.json
	chmod 0755 debian/M4_PACKAGE_NAME/var/www/M4_DS_PREFIX/server/DocService/docservice || true
	chmod 0755 debian/M4_PACKAGE_NAME/var/www/M4_DS_PREFIX/server/tools/allthemesgen || true
	chmod 0755 debian/M4_PACKAGE_NAME/var/www/M4_DS_PREFIX/server/tools/pluginsmanager || true
	chmod 0755 debian/M4_PACKAGE_NAME/var/www/M4_DS_PREFIX/server/tools/allfontsgen || true
	chmod 0755 debian/M4_PACKAGE_NAME/var/www/M4_DS_PREFIX-example/example || true

override_dh_builddeb:
	dh_builddeb -- -z9 -Zxz --threads-max=$(shell nproc)
