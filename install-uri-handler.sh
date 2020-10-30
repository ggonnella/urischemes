#!/usr/bin/env bash
# %-PURPOSE-%
purpose="Install a MIME handler for a URI scheme"
version="1.0"

scriptdir=$(dirname $(readlink -f $0))

eval "$(docopts -V $version -h - : "$@" <<-END_OF_HELP
$purpose

Usage:
   install-uri-handler.sh [options] <scheme>

Arguments:
      scheme         scheme to install

Options:
      --opener FILENAME  opener filename
                         (default: $scriptdir/<scheme>-opener.desktop)
      --force            force installation if opener already installed
      --help, -h         show this page
      --version, -V      print program version

Examples:
   generate-uri-handler.sh wikipedia https://%s.wikipedia.com/%s en > wikipedia-opener.desktop
   install-uri-handler.sh wikipedia
END_OF_HELP
)"


if [ "$opener" == "" ]; then
  openerbn=${scheme}-opener.desktop
  opener=${scriptdir}/${openerbn}
else
  opener=$(readlink -f $opener)
  openerbn=$(basename $opener)
fi

if [ ! -f "$opener" ]; then
  echo "ERROR: I can't find the opener $opener"
  exit 1
fi

appsdir=${XDG_DATA_HOME-$HOME/.local/share}/applications
cd $appsdir
if [ -e "$openerbn" ]; then
  if ! $force; then
    echo "ERROR: the opener was already installed"
    echo "installation directory: $appsdir"
    exit 1
  fi
fi

ln -f -s ${opener}
echo "# linked $opener to directory $appsdir"
xdg-mime default ${openerbn} x-scheme-handler/${scheme}
echo "# registered $opener to handle ${scheme}: scheme"
echo "# command to check if it was registered correctly:"
echo "xdg-mime query default x-scheme-handler/${scheme}"
echo "# test an URI"
echo "xdg-open ${scheme}://a/b"
