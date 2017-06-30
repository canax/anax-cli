#!/usr/bin/env bash
#
# Anax CLI utility to work with Anax websites.
#
VERSION="\
v1.0.x (2017-06-30)
"

BADUSAGE="\
For an overview of the command, execute:
anax --help
"

USAGE="\
Utility to work with Anax web sites.
Usage: anax [options] <command> [arguments]

Command:
  check [url]           Check all links starting from url.

Options:
    --help, -h          Show info on how to use it.
    --output [format]   Set the output format, default is text.
"



#
#
#
function anax-check
{
    :
}



#
# Parse incoming options and arguments
#
while (( $# )); do
    case "$1" in
        --help | -h)
            printf "%s" "$USAGE"
            exit 0
        ;;

        --version | -v)
            printf "%s" "$VERSION"
            exit 0
        ;;

        # check)
        #     COMMAND=$1
        #     shift
        #     URL=$( echo $1 | sed 's/[\/]*$//')
        #     shift
        # ;;

        *)
            ARGS+=("$1")
            shift
        ;;
    esac
done



# Execute the command 
if type -t linkchecker-"$COMMAND" | grep -q function; then
    linkchecker-"$COMMAND"
else
    printf "%s" "$BADUSAGE"
    exit 1
fi
