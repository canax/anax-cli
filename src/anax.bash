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
    printf "v1.0.3 (2017-08-05)\\n"
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
 check                    Check and display details on local environment.
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
# Print confirmation, call with a prompt string or use a default
#
confirm()
{
    read -r -p "${1:-Are you sure? [yN]} "
    case "${REPLY:-$2}" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
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
# Check details on local environment
#
anax_check()
{
    local red
    local normal

    red=$(tput setaf 1)
    normal=$(tput sgr0)

    echo "### Checking system" && uname -a
    for tool in bash curl rsync git php composer make; do
        printf "\\n### Checking %s\\n" "$tool"
        which $tool && $tool --version || printf "%s %s\\n" "${red}[MISSING]${normal}" "$tool"
    done

    printf "\\n### Checking config dir '%s'\\n" "$ANAX_CONFIG_DIR"
    if [[ -d $ANAX_CONFIG_DIR ]]; then
        ls -l "$ANAX_CONFIG_DIR"
    else
        printf "%s %s\\n" "${red}[MISSING]${normal} config directory, but you can do without it."
    fi
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
    local scaffold=
    local external="https://raw.githubusercontent.com/canax/scaffold/master/scaffold"

    config_read

    # Check dir 
    [[ ! $dir ]] && fail "Missing name of directory to create the site in, must be non-existing directory."

    [[ -e "$dir" && ! $FORCE ]] && fail "The directory '$dir' exists, use another dirname."

    printf "Creating a new Anax site in directory '%s' using template '%s'.\\n" "$dir" "$template"

    install -d "$dir" || fail "Could not create the directory '$dir'."

    [[ ! $template ]] && fail "Missing template name to use." 

    scaffold="$ANAX_CONFIG_DIR/scaffold/$template"
    if [[ -d $scaffold ]]; then
        printf "Found (and using) local scaffold template in:\\n%s\\n" "$scaffold"
        rsync -a "$scaffold/" "$dir/"
    else
        printf "Using external template from:\\n%s\\n" "$external/$template"
        local file="$template.tar.gz"
        local source="$external/$file"
        curl --silent --fail --output "$file" "$source" || fail "Failed downloading external template '$source'."
        curl --silent --fail --output "$file.sha1" "$source.sha1" || fail "Failed downloading sha1 '$source.sha1'."
        sha1sum -c "$file.sha1" || fail "Sha1 checksum did not match."
        tar xzf $file -C "$dir" || fail "Could not read tar archive."
        rm "$file" "$file.sha1"
    fi

    printf "Directory '$dir' is now scaffolded.\\n" "$dir"
    ls -l "$dir"
    confirm "Execute postprocessing by 'make scaffold-setup'? [Yn]" "Y" && cd "$dir" && make scaffold-setup
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

            check       | \
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
