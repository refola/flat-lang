#!/usr/bin/env bash
## main.sh
# filst interpreter for flat-lang


# string variables
declare -A strings

# set-string string-name string
set-string() { strings["$1"]="${*:2}"; }

# get-string string-name
## outputs the corresponding string contents
get-string() { echo "${strings[$1]}"; }

# verbs associative array
## format
# each index is the name of a verb. the string at that index is the
# name of the command to run for the verb (this should be either a
# shell function or a command in $PATH). indices like "verb 1",
# ... give (possibly empty) arguments that are always used with the
# verb's associated command, which are to be prepended to any
declare -A verbs

# set-verb verb-name underlying-command [args ...]
set-verb() {
    local verb="$1" i=1
    unset-verb "$verb"
    verbs["$verb"]="$2"
    shift 2
    while [ "$i" -lt "$#" ]; do
        verbs["$verb $i"]="${!i}"
    done
    set-string "$verb" "$verb"
}

# set-verb-function verb-name function-name
set-verb-function() {
    verbs["$1"]="fn $2"
}

# unset-verb verb-name
unset-verb() {
    is-verb "$1" || return 0
    unset verbs["$1"]
    local i=1
    while test -v verbs["$1 $i"]; do
        unset verbs["$1 $i"]
        ((i++))
    done
}

# is-verb verb-name
## returns 0 exit code iff verb-name is a known verb
is-verb() {
    test -v verbs["$1"]
}

# get-verb verb-name
## outputs lines for the verb's command and arguments that the verb
## supplies to the command
get-verb() {
    is-verb "$1" || return 1
    echo "${verbs[$1]}"
    local i=1
    while test -v verbs["$1 $i"]; do
        echo verbs["$1 $i"]
        ((i++))
    done
}

## outputs each known verb on its own line
list-verbs() {
    local verb
    for verb in "${!verbs[@]}"; do
        echo "$verb"
    done
}


## echo args to standard error and exit with nonzero status
fail() {
    echo "$*" >&2
    exit 1
}

# dbg args [...]
## output args to stderr
dbg() {
    echo -e "\e[1m$*\e[0m" >&2
    true
}


# run it
main() {
    local here="$(dirname "$(readlink -f "$0")")"
    # shellcheck source=run.sh
    source "$here/run.sh" # parse/interpret logic
    # shellcheck source=builtins.sh
    source "$here/builtins.sh" # magic builtins
    run "$here/builtins.flat" # derived builtins
    run "$@" # user program with args
}
main "$@"
