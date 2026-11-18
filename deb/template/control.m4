include(variables.m4)
Source: M4_PACKAGE_NAME
Section: web
Priority: optional
Maintainer: M4_PUBLISHER_NAME <M4_SUPPORT_MAIL>
Build-Depends: debhelper (>= 8.0.0), util-linux (>= 2.38)

Package: M4_PACKAGE_NAME
Architecture: M4_DEB_ARCH
Depends: ${shlibs:Depends}, ${misc:Depends}, 
  adduser,
  ca-certificates,
  certbot,
  coreutils,
  curl,
  libcairo2,
  libcurl3 | libcurl4,
  libcurl3-gnutls,
  libstdc++6 (>= 4.8.4),
  libxml2,
  logrotate,
  nginx-extras (>= 1.3.13),
  postgresql-client (>= 9.1) | mysql-client | mysql-community-client | mariadb-client,
ifelse(eval(ifelse(M4_PRODUCT_NAME,documentserver-ee,1,0)||ifelse(M4_PRODUCT_NAME,documentserver-ie,1,0)||ifelse(M4_PRODUCT_NAME,documentserver-de,1,0)),1,
`  redis-tools,'
,)dnl
  ttf-mscorefonts-installer,
  openssl,
  xxd,
  zlib1g
Recommends:
  sudo,
Description: defn(`DEB[Summary]')
defn(`DEB[Description]')
