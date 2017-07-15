#!/usr/bin/env bash
#
# Anax CLI utility to work with Anax websites.
#

#
# Globals (prefer none)
# 



#
# Print out current version
#
version()
{
    printf "v1.0.1 (2017-07-15)\\n"
}



#
# Print out how to use
#
usage()
{
    printf "\
Utility to work with Anax web sites.
Usage: anax [options] <command> [arguments]

Command:
  check [url]           Check all links starting from url.

Options:
    --help, -h          Show info on how to use it.
    --output [format]   Set the output format, default is text.
"
}



#
# Print out how to use
#
bad_usage()
{
    [[ $1 ]] && printf "%s\\n" "$1"

    printf "\
For an overview of the command, execute:
anax --help
"
}



#
# Error while processing
#
fail()
{
    local red
    local normal

    red=$(tput setaf 1)
    normal=$(tput sgr0)

    printf "%s %s\\n" "${red}[FAILED]${normal}" "$*"
    exit 2
}



#
# Create a new site
#
anax_create()
{
    local dir=$ARGS

    [[ ! $dir ]] && fail "Missing name of directory to create the site in, must be non-existing directory."

    [ -e "$dir" ] && fail "The directory exists, use another path where a new directory can be created."

    echo "Creating a new Anax site in directory '$dir'."
    install -d "$dir" || echo "failed"
}



#
# Always have a main
# 
main()
{
    # Parse incoming options and arguments
    while (( $# )); do
        case "$1" in
            --help | -h)
                usage
                exit 0
            ;;

            --version | -v)
                version
                exit 0
            ;;

            create)
                COMMAND=$1
                shift
            ;;

            *)
                if [[ ! $COMMAND ]]; then
                    bad_usage "Unknown option/command/argument '$1'."
                    exit 1
                fi
                ARGS+=("$1")
                shift
            ;;
        esac
    done



    # Execute the command 
    if type -t anax_"$COMMAND" | grep -q function; then
        anax_"$COMMAND"
    else
        bad_usage "Missing command."
        exit 1
    fi
}



main "$@"
