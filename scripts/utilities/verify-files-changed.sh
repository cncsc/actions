#!/usr/bin/env bash

function main() {
  local changeset
  local -r base_directory="$1"
  local -r grep_pattern="$2"

  echo "Complete changeset:"

  git --no-pager show -m --name-only

  echo ""
  echo "Looking for files in ./${base_directory}/ matching '${grep_pattern}'"
  changeset="$(git --no-pager show -m --name-only)"
  changeset="$(echo "$changeset" | grep -E "^$base_directory/.*")"
  changeset="$(echo "$changeset" | grep -E "$grep_pattern" || true)"

  if [ -z "$changeset" ]; then
    echo "Changeset did not contain any matching files."
    echo ""
    echo "files_changed=false" >> "$GITHUB_OUTPUT"
  else
    echo "Changeset contained the following matching files:"
    echo "$changeset"
    echo ""

    local json_changeset
    json_changeset='[]'

    while read -r line
    do
      json_changeset="$(echo "$json_changeset" | jq ".[. | length] = \"$line\"")"
    done < <(echo "$changeset")

    json_changeset="$(echo "$json_changeset" | jq -r tostring)"

    echo "files_changed=true" >> "$GITHUB_OUTPUT"
    echo "changeset='$json_changeset'" >> "$GITHUB_OUTPUT"
  fi
}

main "$@"
