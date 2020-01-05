#!/bin/sh

set -e

autoreconf

(
cd po
export XGETTEXT="xgettext -kP_:1,2"
intltool-update --pot
## Translations are managed at https://www.transifex.com/telegram-purple-developers/telegram-purple/
## To update the .po files, download it from there, since intltool, msginit, and transifex produce slightly different files, and I'd like to avoid gigantic git diffs that only change indentation or similar things.

## Also, for some reason, the header generated by GNU intltool does not conform to
## What GNU.org says the header should look like.  So, let's fix it.

## First, check whether the header is exactly as expected.
oldlines=20
tmpfile=$(mktemp)
head -n ${oldlines} telegram-purple.pot | grep -v '^"POT-Creation-Date:' > ${tmpfile}
if ! diff -u ${tmpfile} pot_header.old
then
    echo "Unexpected header of telegram-purple.pot!  Please check by hand."
    rm ${tmpfile}
    exit 2
fi
rm ${tmpfile}

## Great, now replace the header by what we want it to be.
tmpfile=$(mktemp)
cat pot_header.new >> ${tmpfile}  # Off by one: missing newline at end
tail -n +${oldlines} telegram-purple.pot >> ${tmpfile}  # Off-by-one: extra newline at beginning
# Together, this works out exaclty, and saves me from computing $oldlines+1
cp ${tmpfile} telegram-purple.pot
rm ${tmpfile}

)

test -r Makefile || ./configure -q
make --quiet build-nsi
