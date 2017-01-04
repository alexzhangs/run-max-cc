#!/bin/bash -e

[[ $DEBUG -gt 0 ]] && set -x || set +x

function usage () {
    printf "Run a command in maximum N concurrent processes.\n\n"

    printf "${0##*/}\n"
    printf "\t[-n NUM]\n"
    printf "\t[-p PATTERN]\n"
    printf "\tCOMMAND [PARAMETER] ...\n"
    printf "\t[-h]\n\n"

    printf "OPTIONS\n"
    printf "\t[-n NUM]\n\n"
    printf "\tRun command in <Num> concurrent processes.\n"
    printf "\tDefault is 0, means unlimited.\n\n"

    printf "\t[-p PATTERN]\n\n"
    printf "\tPattern used to filter the process in process list.\n"
    printf "\tDefault pattern is the COMMAND name without PARAMETER.\n\n"

    printf "\tCOMMAND [PARAMETER] ...\n\n"
    printf "\tCommand to run and parameters to pass.\n\n"

    printf "\t[-h]\n\n"
    printf "\tThis help.\n\n"
    exit 255
}

function get_descendent_process () {
    local pids=( $(ps -o %p --no-heading --ppid $1) )
    local pid
    for pid in "${pids[@]}"; do
        echo $pid
        get_descendent_process $pid
    done
}

function get_process_num_by_pattern () {
    local pids=( $$ $(get_descendent_process $$) )
    ps -o args --no-heading -N --pid "$(echo "${pids[@]}" | sed 's/ /,/g')" \
        | egrep "$1" \
        | grep -v grep \
        | wc -l
}


max=0
pattern=''
while getopts n:p:h opt; do
    case $opt in
        n)
            max=$OPTARG
            ;;
        p)
            pattern=$OPTARG
            ;;
        h)
            usage
            ;;
    esac
done
shift $((OPTIND - 1))

[[ $# -eq 0 ]] && usage

if [[ -z $pattern ]]; then
    pattern=$1
fi

if [[ $max -eq 0 ]]; then
    "$@"
else
    cc=$(get_process_num_by_pattern "$pattern")
    if [[ $cc -lt $max ]]; then
        "$@"
    else
        echo "${0##*/}: running: $cc, max: $max, skipped to run: $*"
    fi
fi

exit
