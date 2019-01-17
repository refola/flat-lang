#!/usr/bin/env bash
## builtins.sh
# magic built-ins that can't be built in flat

# verb my-verb base-verb args1...:
#    my-verb args2...
# -> base-verb args1... args2...
set-verb-function verb set-verb
#verbs[verb]='set-verb'

# run a command
set-verb-function cmd cmd
#verbs[cmd]='cmd'
cmd() { "$@"; }

# set a string variable
set-verb-function string set-string
#verbs[string]='set-string'
