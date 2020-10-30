#!/usr/bin/env bash
# %-PURPOSE-%
purpose="Convert a schema:[pfx/]id URI to e.g. a https URL"
version="1.0"

eval "$(docopts -V $version -h - : "$@" <<-END_OF_HELP
$purpose

If the URI is not in the specified schema, then the input value
is returned unchanged.

Usage:
      handle-uri.sh [options] <uri> <schema> <template>

Arguments:
      uri        input uri

      schema     schema

      template   template to apply, should contain a single "%s", which
                 will be replaced with the path (or two "%s" with --default,
                 see below)

Options:
     -d STR, --default STR            default value to apply if the path consists of a
                                      single segment only, i.e. the URI contains no /
                                      (not considering the optional initial //);
                                      in this case template must contain two "%s"
                                      and the _first_ one is used for the default
                                      or for the extracted first path segment;
                                      this allows to create shorter URIs for a default
                                      parameter, e.g. username, language...
     -c TEMPLATE, --cmd CMD_TEMPLATE  Use a command to open the uri.
                                      The argument must contain a single
                                      %s which is substituted with
                                      the result of the conversion.
                                      (default: echo "%s")
     --verbose                        output additional information

Examples:

  $ handle-uri.sh google:gfapy google https://google.com/search?q=%s
  https://google.com/search?q=gfapy
  $ # return unchanged if the URI is not the specified schema
  $ handle-uri.sh github:gfapy google https://google.com/search?q=%s
  github:gfapy
  $ # example usage of the --default option:
  $ handle-uri.sh github://gfapy github https://github.com/%s/%s -d ggonnella
  https://github.com/ggonnella/gfapy
  $ handle-uri.sh github://a/b github https://github.com/%s/%s -d ggonnella
  https://github.com/a/b
  $ # open the converted URI passing it to xdg-open
  $ handle-uri.sh google:gfapy google https://google.com/search?q=%s -c "xdg-open %s"
END_OF_HELP
)"

function verbose {
  if $verbose; then echo "$*"; fi
}

verbose "# initial uri = '$uri'"
verbose "# expected schema = '$schema'"
if [[ "$uri" == "$schema:"* ]]; then
  verbose "# schema found"
  path=${uri#$schema:}
  path=${path#//}
  verbose "# path component of uri = '$path'"
  if [ "$default" != "" ]; then
    verbose "# default option found, set to: '$default'"
    sep='/'
    case $path in
      (*"$sep"*)
        before=${path%%"$sep"*}
        path=${path#*"$sep"}
        verbose "# path has at least two segments"
        ;;
      (*)
        before=$default
        path=$path
        verbose "# path has only one segment"
        verbose "# use default value as first segment"
        ;;
    esac
    verbose "# apply first segment and path to uri"
    verbose "# first segment value: '$before'"
    verbose "# current value of path: '$path'"
    uri=$(printf "$template" "$before" "$path" )
    verbose "# current value of uri: '$uri'"
  else
    verbose "# default option not found, apply path"
    uri=$(printf "$template" "$path")
    verbose "# current value of uri: '$uri'"
  fi
fi

if [ "$cmd" == "" ]; then
  verbose "# no cmd provided, thus use default"
  cmd='echo %s'
fi
verbose "# cmd is: '$cmd'"
cmd=$(printf "$cmd" \""$uri\"")

verbose "# apply cmd to uri"
verbose "# cmd is: '$cmd'"

eval "$cmd"
