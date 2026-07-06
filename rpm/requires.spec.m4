Requires: nginx >= 1.3.13, curl, wget, libstdc++ >= 4.8.4, libcurl, zlib, atk, gtk3, libXtst, alsa-lib, libselinux-utils, liberation-mono-fonts, logrotate, ca-certificates, msttcore-fonts-installer, openssl, vim-common
ifelse(regexp(M4_PACKAGE_NAME, `documentserver$'),-1,`Requires: certbot, (postgresql >= 12 or /usr/bin/psql)',)
