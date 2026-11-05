#!/usr/bin/env bash
# Renders debian/copyright and fails if upstream additional terms come back
# or the Section 7(a) warranty term goes missing, and renders NOTICE with the
# documentserver recipe's m4 call and fails if it lacks the ONLYOFFICE origin
# notice for the brand.
set -eu
cd "$(dirname "$0")/.."
make -B deb/build/debian/copyright
copyright=deb/build/debian/copyright
if grep -nE 'Product logo|7\(b\)|7\(e\)' "$copyright"; then
  echo "::error::upstream additional terms are back in debian/copyright"
  exit 1
fi
tr -s ' \n' '  ' < "$copyright" | grep -qF 'In accordance with Section 7(a) of the GNU AGPL its Section 15 shall be amended to the effect that Ascensio System SIA expressly excludes the warranty of non-infringement of any third-party rights.' \
  || { echo "::error::debian/copyright lacks the Section 7(a) warranty term"; exit 1; }
for brand in 'Euro-Office' 'Nextcloud Office'; do
  render=$(make -n documentserver COMPANY_NAME="$brand" | sed -n 's/^\(m4 .* NOTICE\.m4\) > .*/\1/p')
  [ -n "$render" ] || { echo "::error::the documentserver recipe no longer renders NOTICE"; exit 1; }
  eval "$render" | tr -s ' \n' '  ' | grep -qF "$brand is based on the original ONLYOFFICE software developed by Ascensio System SIA. $brand is not affiliated with" \
    || { echo "::error::$brand NOTICE lacks the ONLYOFFICE origin notice"; exit 1; }
done
