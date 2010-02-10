#!/bin/bash

# Filename:      bashutils-messages.sh
# Description:   A set of functions for giving the user information.
# Maintainer:    Jeremy Cantrell <jmcantrell@gmail.com>
# Last Modified: Tue 2010-02-09 22:59:57 (-0500)

# autodoc-begin bashutils-messages {{{
#
# The messages library provides functions for notifying the user.
#
# All functions are sensitive to the following variables:
#
#     GUI      # If set/true, try to use gui dialogs.
#     VERBOSE  # If unset/false, the user will not see notifications.
#
# The VERBOSE variable only matters if the function is used with the verbose
# mode check option (-c).
#
# autodoc-end bashutils-messages }}}

if (( ${BASH_LINENO:-0} == 0 )); then
    source bashutils-autodoc
    autodoc_execute "$0" "$@"
    exit
fi

[[ $BASHUTILS_MESSAGES_LOADED ]] && return

source bashutils-modes
source bashutils-terminfo
source bashutils-utils

z() #{{{1
{
    local text=$1; shift
    zenity --title="$text" --text="$text:" "$@"
}

usage() #{{{1
{
    # autodoc-begin usage {{{
    #
    # Display usage information.
    #
    # Will automatically populate certain sections if things like verbose or
    # interactive modes are set (either on or off).
    #
    # Required variables:
    #
    #     SCRIPT_NAME
    #
    # Optional variables:
    #
    #     SCRIPT_ARGS
    #     SCRIPT_USAGE
    #     SCRIPT_DESCRIPTION
    #     SCRIPT_EXAMPLES
    #     SCRIPT_OPTIONS
    #
    # autodoc-end usage }}}

    if [[ $SCRIPT_NAME ]]; then
        local p="    "
        {
            echo "Usage: $SCRIPT_NAME [OPTIONS] $SCRIPT_ARGS"
            [[ $SCRIPT_USAGE ]] && echo "$SCRIPT_USAGE"

            if [[ $SCRIPT_DESCRIPTION ]]; then
                echo
                echo -e "$SCRIPT_DESCRIPTION"
            fi

            if [[ $SCRIPT_EXAMPLES ]]; then
                echo
                echo "EXAMPLES"
                echo
                echo -e "$SCRIPT_EXAMPLES"
            fi

            echo
            echo "GENERAL OPTIONS"
            echo
            echo "${p}-h    Display this help message."

            if [[ $INTERACTIVE ]]; then
                echo
                echo "${p}-i    Interactive. Prompt for certain actions."
                echo "${p}-f    Don't prompt."
            fi

            if [[ $VERBOSE ]]; then
                echo
                echo "${p}-v    Be verbose."
                echo "${p}-q    Be quiet."
            fi

            if [[ $SCRIPT_OPTIONS ]]; then
                echo
                echo "APPLICATION OPTIONS"
                echo
                echo -e "$SCRIPT_OPTIONS" | sed "s/^/${p}/"
            fi
        } | squeeze_lines >&2
    fi
}

usage_exit() #{{{1
{
    # autodoc-begin usage_exit {{{
    #
    # Usage: usage_exit [ERROR]
    # Display usage information and exit with the given error code.
    #
    # autodoc-end usage_exit }}}

    usage; exit ${1:-0}
}

error() #{{{1
{
    # autodoc-begin error {{{
    #
    # Usage: error [-c] [MESSAGE]
    # Displays a colorized (if available) error message.
    #
    # autodoc-end error }}}

    local check

    unset OPTIND
    while getopts ":c" option; do
        case $option in
            c) check=1 ;;
        esac
    done && shift $(($OPTIND - 1))

    if truth $check && ! verbose; then
        return
    fi

    local msg=${1:-An error has occurred.}

    if gui; then
        z "$msg" --error
    else
        info "${term_fg_red}${term_bold}ERROR: ${msg}${term_reset}"
    fi
}

error_exit() #{{{1
{
    # autodoc-begin error_exit {{{
    #
    # Usage: error_exit [MESSAGE] [ERROR]
    # Displays an error message and exits with the given error code.
    #
    # autodoc-end error_exit }}}

    error "$1"; exit ${2:-1}
}

info() #{{{1
{
    # autodoc-begin info {{{
    #
    # Usage: info [-c] [MESSAGE]
    # Displays a colorized (if available) informational message.
    #
    # autodoc-end info }}}

    local check

    unset OPTIND
    while getopts ":c" option; do
        case $option in
            c) check=1 ;;
        esac
    done && shift $(($OPTIND - 1))

    if truth $check && ! verbose; then
        return
    fi

    local msg=${1:-All updates are complete.}

    if gui; then
        z "$msg" --info
    else
        echo -e "${term_bold}${msg}${term_reset}" >&2
    fi
}

warn() #{{{1
{
    # autodoc-begin warn {{{
    #
    # Usage: warn [-c] [MESSAGE]
    # Displays a colorized (if available) warning message.
    #
    # autodoc-end warn }}}

    local check

    unset OPTIND
    while getopts ":c" option; do
        case $option in
            c) check=1 ;;
        esac
    done && shift $(($OPTIND - 1))

    if truth $check && ! verbose; then
        return
    fi

    local msg=${1:-Are you sure you want to proceed?}

    if gui; then
        z "$msg" --warning
    else
        info "${term_fg_yellow}${term_bold}WARNING: ${msg}${term_reset}"
    fi
}

#}}}1

BASHUTILS_MESSAGES_LOADED=1