#!/usr/bin/env bash
## builtins.sh
# magic built-ins that can't be built in flat

# verb my-verb base-verb args1...:
#    my-verb args2...
# -> base-verb args1... args2...
verbs[verb]='verb'
verb() {
    local v="$1"
    shift
    verbs["$v"]="$@"
}

# run a command
verbs[cmd]='cmd'
cmd() { "$@"; }
