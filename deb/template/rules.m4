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
	chmod o-rwx debian/M4_PACKAGE_NAME/etc/M4_DS_PREFIX/*.json
	find debian/M4_PACKAGE_NAME/var/www/M4_DS_PREFIX \
		\( -path '*/server/DocService/docservice' \
		-o -path '*/server/tools/allthemesgen' \
		-o -path '*/server/tools/pluginsmanager' \
		-o -path '*/server/tools/allfontsgen' \
		-o -path '*/server/FileConverter/bin/x2t' \
		-o -path '*/server/FileConverter/bin/HtmlFileInternal/HtmlFileInternal' \) \
		-type f -exec chmod 0755 {} \; || true

	find debian/M4_PACKAGE_NAME/var/www/M4_DS_PREFIX-example \
		-path '*/example' -type f -exec chmod 0755 {} \; || true

override_dh_builddeb:
	dh_builddeb -- -z9 -Zxz --threads-max=$(shell nproc)
