#!/usr/bin/env bash
#
# Anax CLI utility to work with Anax websites.
#
VERSION="\
v1.0.0 (2017-06-30)
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

# Color ouput
RED=$(tput setaf 1)
NORMAL=$(tput sgr0)



#
# Error while processing
#
function fail
{
    printf "%s\n" "${RED}[FAILED]${NORMAL} $*"
    exit 2
}



#
# Create a new site
#
function anax-create
{
    local dir=$ARGS

    [[ ! $dir ]] && fail "Missing name of directory to create the site in, must be non-existing directory."

    [ -e "$dir" ] && fail "The directory exists, use another path where a new directory can be created."

    echo "Creating a new Anax site in directory '$dir'."
    install -d "$dir" || echo "failed"
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

        create)
            COMMAND=$1
            shift
        ;;

        *)
            [[ ! $COMMAND ]] && printf "%s\n%s" "Unknown option/command/argument '$1'." "$BADUSAGE" && exit 1
            ARGS+=("$1")
            shift
        ;;
    esac
done



# Execute the command 
if type -t anax-"$COMMAND" | grep -q function; then
    anax-"$COMMAND"
else
    printf "%s" "$BADUSAGE"
    exit 1
fi
