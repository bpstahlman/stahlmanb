#! /usr/bin/bash
# Get name of "target" program: i.e., the one being wrapped.
target=$1
shift
# Design Decision: Don't be strict about mixing forward/back slashes. It shouldn't happen, but if it does, cygpath can handle.
sep=[/\\]
isf=[^[:space:]/\\]
declare -a args=()
for arg in "$@"; do
	# Decision: To avoid spurious conversions, require at least 1 slash in the path.
	if [[ $arg =~ ^([^=[:space:]]+=)?([A-Za-z]:$sep($isf+$sep?)*)$ ]]; then
		# BASH_REMATCH[1] will be empty unless the path appears after --long-opt=
		# Assumption: A path supplied to short opt will be a separate arg.
		arg="${BASH_REMATCH[1]}$(cygpath -u "${BASH_REMATCH[2]}")"
	fi
	args+=($arg)
done
# Run the target with converted args.
$target "${args[@]}"

