#!/usr/bin/env bash
# %-PURPOSE-%
purpose="Generates a MIME handler for a URI scheme"
version="1.0"

eval "$(docopts -V $version -h - : "$@" <<-END_OF_HELP
$purpose

Usage:
      generate-uri-handler.sh [options] <name> <conversion> [<default>]

Arguments:
      name         name of the scheme
      conversion   template to pass to convert-uri.sh
      default      parameter of convert-uri.sh --default

Options:
      -f NAME, --formatted NAME   formatted name used in the Name field
                                  default: name, with first letter capitalized
      --help, -h                  show this page
      --version, -V               print program version

Examples:
      generate-uri-handler.sh github https://github.com/%s/%s ggonnella
      generate-uri-handler.sh wikipedia https://%s.wikipedia.com/wiki/%s en
      generate-uri-handler.sh google https://www.wikipedia.com/search?query=%s
END_OF_HELP
)"

if [ "$formatted" == "" ] ; then
  formatted=${name^}
fi

if [ "$default" != "" ]; then
  default="-d $default"
fi

cat <<-END_OF_ENTRY
[Desktop Entry]
Type=Application
Name=${formatted} URI Scheme Handler
Exec=handle-uri.sh %u ${name} '${conversion}' ${default} -c 'xdg-open %s'
StartupNotify=false
MimeType=x-scheme-handler/${name};
END_OF_ENTRY
