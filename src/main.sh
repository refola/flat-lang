#!/usr/bin/env bash
## main.sh
# filst interpreter for flat-lang

# verbs associative array
## format
# each index is the name of a verb. the string at that index is a 
declare -A verbs

# run it
main() {
    local here="$(dirname "$(readlink -f "$0")")"
    # shellcheck source=run.sh
    source "$here/run.sh" # parse/interpret logic
    # shellcheck source=builtins.sh
    source "$here/builtins.sh" # magic builtins
    run "$here/init.flat" # derived builtins
    run "$@" # user program with args
}
main "$@"
