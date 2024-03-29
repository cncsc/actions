#!/usr/bin/env bash

function main() {
  local changeset
  local -r base_directory="$1"
  local -r grep_pattern="$2"
  local -r current_hash="$(git rev-parse HEAD)"
  # Get the most recent tag, which does not contain HEAD.
  local -r previous_tag="$(git --no-pager tag --sort='-authordate' --no-contains HEAD | head -n1)"
  local -r previous_hash="$(git --no-pager tag --sort='-authordate' --no-contains HEAD --format '%(objectname)' | head -n1)"

  echo "Most recent tag was $previous_tag at commit $previous_hash"
  echo "Complete changeset:"

  # This is safe even if previous_tag is an empty string. git-diff will treat previous_tag as HEAD
  git --no-pager diff --name-only "$previous_tag..$current_hash"

  echo ""
  echo "Looking for files in ./${base_directory}/ matching '${grep_pattern}'"
  changeset="$(git --no-pager diff --name-only "$previous_tag..$current_hash")"
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
