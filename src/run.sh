#!/usr/bin/env bash
## run.sh
# the running of flat files

parse-line() {
    true
}
run-verb() {
    first="${line[0]}"
    line[0]=
    ${verbs["$first"]} "${line[@]}"
}

# run a flat-lang source file, keeping assignments in $verbs
run() {
    local file="$1" raw_line first line=() token
    # TODO: make external args usable inside flat
    while read -r raw_line; do
        line=()
        parse-line "$raw_line" | while read -r token; do
            line+=("$token")
        done
        run-verb "${line[@]}"
    done < "$file"
}
