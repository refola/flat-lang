# flat-lang

flat-lang is an unindented "one line at a time" imperative programming
language built as an experiment in making an "unstructured" language
with even less syntax than Lisps, just to see how far I can get and
how quickly.


# syntax

## meta-syntax

when describing flat's syntax, this document uses the following
syntax.

- `[square brackets]` denote optional things.
- `ellipses...` denote variadic things.
- `{curly brackets}` denote descriptions of what must be there
- everything else in formal syntax denotes its literal self,
  particularly in examples

## flat syntax

- __verbs__ start lines `{verb} [{arg}...]` with space-separated
  arguments.
  - e.g., `printf 'hello flat\n'`
- __arguments__ are either strings or variables.
- __strings__ are single quoted `'{string}'`.
    - __quotes inside strings__ are done with two single quotes:
      `'{left}''{right}'` yields a string with `left` followed by `'`
      and `right`.
        - e.g., `'this is a ''string'''` parses to a string containing
          `this is a 'string'`, and a string containing a single
          single quote is represented as `''''`.
- __comments__ are done by starting a lines with leading octothorpes
  `#{comment}`, which are not special anywhere else.
    - __first lines in files__ can be set to `#!/usr/bin/env flat` in
      an executable flat file so it can be ran like a shell script, as
      an intentional side effect of the comment symbol.
- __other syntax__ i'm adding whatever seems necessary to the magic
  verbs. while such 'syntax' (basically 'magic strings' as arguments)
  has special meaning in certain verbs, there's nothing stopping you
  from using it differently or even making it unmagical in your own
  verbs. that said, i'll try to establish/follow consistent
  conventions when making builtins.


# types

i'm trying to keep it at just verbs, strings, and variables. there
will be no other types or type-checking unless it can be implemented
within flat itself.

- __verbs__ are anything that has a side effect. they can start lines
  or be passed as arguments to other verbs. Note that verbs are
  technically identified by strings, but the standard runtime
  verb-making machinery sets a variable of the same name so that,
  e.g., `my-verb` is the same as `'my-verb'` once it's been defined.
- __strings__ are just data in human-visible form. Multiline strings
  are not representable in flat source code, but using `\n` inside a
  string lets verbs like `printf` output multiline results.
- __variables__ can contain either verbs or strings.


# builtin verbs

oh gods I need to make this computationally interesting....

## magic builtins

as far as i know, these cannot be implemented in flat directly

- `cmd {command} [{args}...]` runs given `command` (found in your
  PATH environment variable) with given `args`
    - e.g., `cmd 'ls' '/home'` in flat is the same as `ls /home` in a
      typical interactive shell.
- `verb {my-verb} {base-verb} [{args}...]` turns `my-verb` into a verb
  that runs preexisting `base-verb`, optionally with given `args`
  prepended to any arguments that `my-verb` may later be ran with.
    - __special syntax__ if an `arg` to `base-verb` is of the form
      `\{number}` then the (1-indexed) `number`'th argument to
      `my-verb` will replace it when `verb` calls `base-verb`.
- `string {name} {contents}` makes a string of given `name`
  containing given `contents`.

## derived builtins

these are implemented in flat, using the magic builtins

- `cmd-verb 'my-cmd'` turns `my-cmd` into a verb.
- `printf format [args ...]` runs some sort of `printf` implementation
  with the given `format` string and arguments.


# miscellaneous

- this is licensed under the MIT License, as given in the `LICENSE` file.
- this is severely broken, and will be missing several vital
  programming features for a very long time.
- don't expect this to become useful, but it would be really funny if
  it does.
- i don't even know if this experiment is well-defined.
- oh gods, what have i done?
