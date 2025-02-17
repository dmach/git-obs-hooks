#!/bin/sh
set -e

COMMIT_MSG_FILE="$1"
COMMIT_SOURCE="$2"
SHA1="${3:-HEAD}"

# {
# 	printf "COMMIT_MSG_FILE: %s\n" "$COMMIT_MSG_FILE" >>/tmp/prepare-commit-msg-log.txt
# 	printf "COMMIT_SOURCE: %s\n" "$COMMIT_SOURCE" >>/tmp/prepare-commit-msg-log.txt
# 	printf "SHA1: %s\n" "$SHA1" >>/tmp/prepare-commit-msg-log.txt
# 	printf "\n"
# } >>/tmp/prepare-commit-msg-log.txt

if test -z "$COMMIT_SOURCE"; then
  if ! git add -- *.changes; then
    echo "Error: Failed to add *.changes files." >&2
    exit 1
  fi

  diff=$(git diff --no-color "$SHA1" -- *.changes \
         | sed -E -n -e '/^\+[^+]/s/^\+//p' \
         | sed -e '/^-\{4,\}/,+1d' \
         | sed -e 's/^- *//')

  if test -n "$diff"
  then  # Check if diff is not empty
    TEMP_COMMIT_MSG=$(mktemp /tmp/moddiff.XXXXXX.msg)
    trap 'rm -f $TEMP_COMMIT_MSG' EXIT
    printf "%s\n" "$diff" >"$TEMP_COMMIT_MSG"
    cat "$COMMIT_MSG_FILE" >>"$TEMP_COMMIT_MSG"
    mv "$TEMP_COMMIT_MSG" "$COMMIT_MSG_FILE"
  fi
fi
