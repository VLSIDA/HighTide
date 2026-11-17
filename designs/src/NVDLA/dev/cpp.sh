#!/bin/sh
# Apple's standalone cpp uses traditional mode, which mishandles indented
# directives in projects.spec. Select C preprocessing explicitly on all hosts.
# vcp pipes its input without a filename; the spec Makefile passes a filename.
# Unlike cpp, a compiler driver requires an explicit '-' for the former case.
has_input=false
skip_arg=false
for arg do
    if "$skip_arg"; then
        skip_arg=false
        continue
    fi
    case "$arg" in
        -o|-imacros|-include|-I|-D|-U) skip_arg=true ;;
        -) has_input=true ;;
        -*) ;;
        *) has_input=true ;;
    esac
done
if ! "$has_input"; then
    set -- "$@" -
fi
exec cc -E -x c "$@"
