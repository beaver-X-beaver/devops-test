#!/usr/bin/env bash
# This script helps 

# Rudimentary check
if [[ -z $CI ]] || [[ $CI != "true" ]]; then
	echo "You are not running this on CI, are you sure about this?"
fi

# Check if JQ exists
if ! command -v jq &> /dev/null
then
	echo "JQ is not in the runner system. Perhaps you are using a non-default runner OS?"
	exit 1
fi

list=$(cargo b -q --message-format json | jq -r '
    select (
         .reason == "compiler-artifact"
     ) | select(
         .target.kind | any(
             . == "cdylib"
         )
     ) | .filenames |
     unique | .[]
')

NARGS=$(echo $list | wc -w)

echo $list | xargs -n $NARGS tar -cf $(pwd)/target/release/projects.tar 1> /dev/null

echo Done

exit 0
