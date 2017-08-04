#!/usr/bin/env bash
#
# Anax CLI utility to work with Anax websites.
#

#
# Globals (prefer none)
# 
readonly ANAX_CONFIG_DIR="$HOME/.anax"


#
# Print out current version
#
version()
{
    printf "v1.0.2* (2017-08-04)\\n"
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
 config                   Create base for configuration in \$HOME/.anax/.
 create <dir> <template>  Create a new site in dir using a template.
 selfupdate               Update to latest version.

Options:
 --help, -h          Show info on how to use it.
 --version, -v       Show info on how to use it.
 --force, -f         Force operation even though it should not.
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
# Read the configuration if it exists
#
config_read()
{
    local configFile="$ANAX_CONFIG_DIR/config"

    # shellcheck source=/dev/null
    [[ -f $configFile ]] && . "$configFile"
}



#
# Create the configuration
#
config_create()
{
    install -d "$ANAX_CONFIG_DIR/scaffold" || fail "Could not create configuration dir: '$ANAX_CONFIG_DIR'"
    touch "$ANAX_CONFIG_DIR/config" || fail "Could not create configuration file: '$ANAX_CONFIG_DIR/config'"
    ls -l "$ANAX_CONFIG_DIR"
}



#
# Create the configuration directory.
#
anax_config()
{
    config_create
}



#
# Create (scaffold) a new site by using a template
#
anax_create()
{
    local dir=${ARGS[0]}
    local template=${ARGS[1]}

    config_read

    [[ ! $dir ]] && fail "Missing name of directory to create the site in, must be non-existing directory."

    [[ -e "$dir" && ! $FORCE ]] && fail "The directory '$dir' exists, use another dirname."

    echo "Creating a new Anax site in directory '$dir' using template '$template'."
    install -d "$dir" || echo "failed"
}



#
# Selfupdate to latest version.
#
anax_selfupdate()
{
    curl --silent https://raw.githubusercontent.com/canax/anax-cli/master/src/install.bash | bash
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

            --force | -f)
                FORCE=1
                shift
            ;;

            create      | \
            config      | \
            selfupdate    )
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
