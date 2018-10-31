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
    printf "v1.1.11 (2018-10-31)\\n"
}



#
# Print out how to use
#
usage()
{
    printf "\
Utility to work with Anax web sites. Read more on:
https://dbwebb.se/anax-cli/
Usage: anax [options] <command> [arguments]

Command:
 check                    Check and display details on local environment.
 config                   Create base for configuration in \$HOME/.anax/.
 create <dir> <template>  Create a new site in dir using a template.
 help                     Show info on how to use it.
 list                     List available templates for scaffolding from.
 list <template>          List details on specific scaffolding template.
 selfupdate               Update to latest version.
 version                  Show info on how to use it.

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
# Check if command is installed
# arg1: The command
#
function has_command() {
    if ! hash "$1" 2> /dev/null; then
        return 1
    fi
    return 0
}



#
# Print confirmation message with default values.
# arg1: The message to display or use default.
# arg2: The default value for the response.
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
# Read input from user supporting a default value for reponse.
# arg1: The message to display.
# arg2: The default value.
#
input()
{
    read -r -p "$1 [$2]: "
    echo "${REPLY:-$2}"
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
    install -d "$ANAX_CONFIG_DIR/scaffold" \
        || fail "Could not create configuration dir: '$ANAX_CONFIG_DIR'"
    touch "$ANAX_CONFIG_DIR/config" \
        || fail "Could not create configuration file: '$ANAX_CONFIG_DIR/config'"
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
        command -v $tool && $tool --version \
            || printf "%s %s\\n" "${red}[MISSING]${normal}" "$tool"
    done

    printf "\\n### Checking config dir '%s'\\n" "$ANAX_CONFIG_DIR"
    if [[ -d $ANAX_CONFIG_DIR ]]; then
        ls -l "$ANAX_CONFIG_DIR"
    else
        printf "%s config directory, but you can do without it.\\n" "${red}[MISSING]${normal} "
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

    [[ ! $dir ]] \
        && fail "Missing name of directory to create the site in, must be non-existing directory."

    [[ -d "$dir" && ! $FORCE ]] \
        && fail "The directory '$dir' exists, use another dirname."

    printf "Creating a new Anax site in directory '%s' using template '%s'.\\n" "$dir" "$template"

    install -d "$dir" \
        || fail "Could not create the directory '$dir'."

    [[ ! $template ]] \
        && fail "Missing template name to use." 

    scaffold="$ANAX_CONFIG_DIR/scaffold/$template"
    if [[ -e $scaffold ]]; then
        printf "Found (and using) local scaffold template in:\\n%s\\n" "$scaffold"
        rsync -a "$scaffold/" "$dir/"
    else
        printf "Using external template from:\\n%s\\n" "$external/$template"
        local file="$template.tar.gz"
        local source="$external/$file"
        curl --silent --fail --output "$file" "$source" \
            || fail "Failed downloading external template '$source'."
        curl --silent --fail --output "$file.sha1" "$source.sha1" \
            || fail "Failed downloading sha1 '$source.sha1'."

        if has_command "sha1sum"; then
            sha1sum -c "$file.sha1" \
                || fail "Sha1 checksum did not match."
        fi

        tar xzf "$file" -C "$dir" \
            || fail "Could not read tar archive."
        rm "$file" "$file.sha1"
    fi

    local postprocess=".scaffold/$template"
    local postprocess1=".scaffold/postprocess.bash"
    local postprocess2=".anax/scaffold/postprocess.bash"
    # Slowly move to rename all postprocessingscript
    if [[ -f $dir/$postprocess2 ]]; then
        postprocess="$postprocess2"
    elif [[ -f $dir/$postprocess1 ]]; then
        postprocess="$postprocess1"
    fi

    if [[ -f $dir/$postprocess ]]; then
        # shellcheck source=/dev/null
        if confirm "Execute postprocessing in '$dir/$postprocess'? [Yn]" "Y"; then
            local commandline=( "./$postprocess" )
            ( cd "$dir" && "${commandline[@]}" ) \
                || fail "Error occured when executing '$postprocess'"
        fi
    else
        printf "Skipping postprocess, script not found.\\n"
    fi

    printf "Directory '%s' is now scaffolded.\\n" "$dir"
    ls -l "$dir"
}



#
# List available scaffold templates, or more info on specific template.
#
anax_list()
{
    local target=${ARGS[0]}
    local tmp="/tmp/anax.$$"
    local url="https://raw.githubusercontent.com/canax/scaffold/master/doc/list.txt"

    if [ "$target" ]; then
        url="https://raw.githubusercontent.com/canax/scaffold/master/doc/$target.txt"
        if ! curl --fail --silent "$url" > "$tmp"; then
            rm -f "$tmp"
            fail "Could not download list file. You need curl and a network connection."
        fi
    elif ! curl --fail --silent "$url" > "$tmp"; then
        rm -f "$tmp"
        fail "Could not download list file. You need curl and a network connection."
    fi

    cat "$tmp"
    rm -f "$tmp"
}



#
# Selfupdate to latest version.
#
anax_selfupdate()
{
    local tmp="/tmp/anax.$$"
    local url="https://raw.githubusercontent.com/canax/anax-cli/master/src/install.bash"

    if ! curl --fail --silent "$url" > "$tmp"; then
        rm -f "$tmp"
        fail "Could not download installations program. You need curl and a network connection."
    fi
    bash < "$tmp"
    rm -f "$tmp"
}



#
# For development and test.
#
anax_develop()
{
    :
}



#
# Always have a main
# 
main()
{
    # Parse incoming options and arguments
    while (( $# )); do
        case "$1" in
            --help | -h | help)
                usage
                exit 0
            ;;

            --version | -v | version)
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
            develop     | \
            list        | \
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
