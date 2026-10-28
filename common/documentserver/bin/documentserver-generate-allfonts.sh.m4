#!/bin/sh

ONLYOFFICE_DATA_CONTAINER=false
if [ "$1" != "" ]; then
    ONLYOFFICE_DATA_CONTAINER=$1
fi

if [ "$2" != "" ]; then
    ONLYOFFICE_K8S_CONTAINER=$2
fi

DIR="/var/www/M4_DS_PREFIX"

export LD_LIBRARY_PATH=/var/www/M4_DS_PREFIX/server/FileConverter/bin:$LD_LIBRARY_PATH

#Start generate AllFonts.js, font thumbnails and font_selection.bin
echo -n Generating AllFonts.js, please wait...


"$DIR/server/tools/allfontsgen"\
  --input="$DIR/core-fonts"\
  --input="$DIR/../Data/custom-fonts"\
  --allfonts-web="$DIR/sdkjs/common/AllFonts.js"\
  --allfonts="$DIR/server/FileConverter/bin/AllFonts.js"\
  --images="$DIR/sdkjs/common/Images"\
  --selection="$DIR/server/FileConverter/bin/font_selection.bin"\
  --output-web="$DIR/fonts"\
  --use-system="true"\
  --use-system-user-fonts="false"

echo Done

echo -n Generating presentation themes, please wait...
"$DIR/server/tools/allthemesgen"\
  --converter-dir="$DIR/server/FileConverter/bin"\
  --src="$DIR/sdkjs/slide/themes"\
  --output="$DIR/sdkjs/common/Images"

"$DIR/server/tools/allthemesgen"\
  --converter-dir="$DIR/server/FileConverter/bin"\
  --src="$DIR/sdkjs/slide/themes"\
  --output="$DIR/sdkjs/common/Images"\
  --postfix="ios"\
  --params="280,224"

"$DIR/server/tools/allthemesgen"\
  --converter-dir="$DIR/server/FileConverter/bin"\
  --src="$DIR/sdkjs/slide/themes"\
  --output="$DIR/sdkjs/common/Images"\
  --postfix="android"\
  --params="280,224"

echo Done

echo -n Generating js caches, please wait...
"$DIR/server/FileConverter/bin/x2t" -create-js-cache

echo Done

# Setting user rights for files created in the previous steps.
# Only the generated ones, by name: the converters in this directory belong to
# root, because the scripts in /usr/bin run them, and this script is one of
# those. Handing the directory over to ds here would put back what the packages
# take away, and a program root runs must not be one ds can rewrite. -h keeps
# chown on a symlink in place of one of these names, as chown -R did before,
# instead of handing ds whatever file the link points at.
if [ "${ONLYOFFICE_K8S_CONTAINER}" != "true" ]; then
  chown -R ds:ds "$DIR/sdkjs"
  chown -h ds:ds \
    "$DIR/server/FileConverter/bin/AllFonts.js" \
    "$DIR/server/FileConverter/bin/font_selection.bin" \
    "$DIR/server/FileConverter/bin/fonts.log" 2>/dev/null
  chown -R ds:ds "$DIR/fonts"
fi

#Remove gzipped files
rm -f \
  $DIR/fonts/*.gz \
  $DIR/sdkjs/common/AllFonts.js.gz \
  $DIR/sdkjs/common/Images/*.gz \
  $DIR/sdkjs/slide/themes/themes.js.gz

#Restart web-site and converter
if [ "$ONLYOFFICE_DATA_CONTAINER" != "true" ]; then
  if pgrep -x ""systemd"" >/dev/null; then
    systemctl restart ds-docservice
    systemctl restart ds-converter
  elif pgrep -x ""supervisord"" >/dev/null; then
    supervisorctl restart ds:docservice
    supervisorctl restart ds:converter
  fi
  documentserver-flush-cache.sh
fi
