#!/usr/bin/env bash
## run.sh
# the running of flat files

# output each parsed literal and looked-up variable string as a
# separate line for use with 'read'
line-strings() {
    local line="$*" i char out
    # skip comments and blank lines
    if [ -z "$line" ] || [ "${line:0:1}" = "#" ]; then
        return
    fi
    while [ -n "$line" ]; do
        char="${line:0:1}"
        # we're at the start of a token
        case "$char" in
            ' '|$'\t') # drop whitespace char
                line="${line:1}"
                ;;
            "'") # find closing quote
                i=1; out=''
                while [ "$i" -lt "${#line}" ]; do
                    char="${line:$i:1}"
                    if [ "$char" != "'" ]; then # normal char
                        out="$out$char" # add char to output
                        ((i++)) # and move to next char
                    elif [ "${line:$i:2}" = "''" ]; then # two single quotes
                        out="$out$char" # add single quote to output
                        ((i+=2)) # and move past ''-encoded single quote
                    else # char is terminal single quote
                        ## TODO: make sure terminal quote is followed
                        ## by whitespace or end of line
                        ((i++)) # advance parser past quoted string
                        break # output has entire token
                    fi
                done
                echo "$out"
                line="${line:$i}"
                ;;
            *) # find end of variable name
                i=1; out="$char"
                while [ "$i" -lt "${#line}" ]; do
                    char="${line:$i:1}"
                    if [ "$char" = "'" ]; then
                        fail "parse error: reached invalid single quote in token starting with '$out' in this line: $*"
                        return 1
                    elif [ "$char" = " " ]; then
                        break
                    else
                        out+="$char"
                        ((i++))
                    fi
                done
                get-string "$out" # we need the underlying string, not the variable
                line="${line:$i}"
                ;;
        esac
    done
}

# run-verb verb [args ...]
## "shopt -s lastpipe" before the "| while" construct prevents both
## these ShellCheck errors.
# shellcheck disable=SC2030,SC2031
run-verb() {
    dbg "run-verb args: $*"
    local verb="$1" last_args=("${@:2}") gotten=() arg
    line[0]=
    last_args=("${line[@]}")
    shopt -s lastpipe || # run loop in same shell so var changes persist
        fail "could not enable 'lastpipe' shell option. please use bash >= 4.2."
    get-verb "$verb" | while read -r arg; do
        dbg "run-verb:piped-while arg: $arg"
        gotten+=("$arg")
    done
    if is-verb "${gotten[0]}"; then
        dbg "run-verb:if gotten: ${gotten[*]}"
        run-verb "${gotten[@]}" "${last_args[@]}"
    elif [ -n "${gotten[0]}" ]; then
        dbg "run-verb:else gotten: ${gotten[*]}"
        dbg "run-verb:else last: ${last_args[*]}"
        "${gotten[@]}" "${last_args[@]}"
    fi
}

# run a flat-lang source file, keeping assignments in $verbs
## "shopt -s lastpipe" before the "| while" construct prevents both
## these ShellCheck errors.
# shellcheck disable=SC2030,SC2031
run() {
    dbg "run args: $*"
    local file="$1" raw_line line=() string
    shopt -s lastpipe || # run loop in same shell so var changes persist
        fail "could not enable 'lastpipe' shell option. please use bash >= 4.2."
    # TODO: make external args usable inside flat (more syntax? :/)
    while read -r raw_line; do
        line=()
        line-strings "$raw_line" | while read -r string; do
            line+=("$string")
            dbg "run:piped-while line: ${line[*]}"
        done
        dbg "run raw_line: $raw_line"
        dbg "run line: ${line[@]}"
        [ -n "${line[0]}" ] && run-verb "${line[@]}"
    done < "$file"
}
