#!/usr/bin/env bash
# Renders debian/copyright and fails if upstream additional terms come back
# or the Section 7(a) warranty term goes missing.
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
