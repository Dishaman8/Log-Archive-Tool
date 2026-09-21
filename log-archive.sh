#!/usr/bin/env bash
# log-archive.sh  | This script  for Archiving  the contents of a log directory into a timestamped tar.gz file.
# Author:Dishaman8 | Date: Sep-21 2026

set -Eeuo pipefail
IFS=$'\n\t'

readonly PROGRAM_NAME="${0##*/}"

usage() {
  cat <<EOF
Usage: $PROGRAM_NAME <log-directory>

Compress the contents of <log-directory> into a timestamped .tar.gz archive.
Archives and the archive log are written to a sibling directory named
<log-directory>_archives (override with ARCHIVE_DIR).

Examples:
  $PROGRAM_NAME /var/log
  ARCHIVE_DIR=/srv/log-archives $PROGRAM_NAME ./logs
EOF
}

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

[[ $# -eq 1 ]] || { usage >&2; exit 2; }
[[ $1 != "-h" && $1 != "--help" ]] || { usage; exit 0; }

command -v tar >/dev/null 2>&1 || fail "tar is required but was not found in PATH"

input_dir=$1
[[ -d $input_dir ]] || fail "log directory does not exist or is not a directory: $input_dir"
[[ -r $input_dir && -x $input_dir ]] || fail "log directory is not readable: $input_dir"

# Resolve the source path first so a trailing slash or relative path cannot affect
# the archive directory name or tar's working directory.
log_dir=$(cd -- "$input_dir" && pwd -P)
archive_dir=${ARCHIVE_DIR:-"${log_dir}_archives"}

if [[ -e $archive_dir && ! -d $archive_dir ]]; then
  fail "archive destination exists but is not a directory: $archive_dir"
fi
mkdir -p -- "$archive_dir" || fail "could not create archive directory: $archive_dir"
[[ -w $archive_dir ]] || fail "archive directory is not writable: $archive_dir"
archive_dir=$(cd -- "$archive_dir" && pwd -P)

# Do not let an explicitly supplied destination live in the directory being packed.
case "$archive_dir/" in
  "$log_dir/"*) fail "archive directory must not be inside the log directory" ;;
esac

timestamp=$(date '+%Y%m%d_%H%M%S')
archive_file="$archive_dir/logs_archive_${timestamp}.tar.gz"
archive_log="$archive_dir/archive.log"

if ! tar -C "$log_dir" -czf "$archive_file" .; then
  rm -f -- "$archive_file"
  fail "failed to create archive"
fi

printf '%s | source=%s | archive=%s\n' \
  "$(date '+%Y-%m-%d %H:%M:%S %z')" "$log_dir" "$archive_file" >> "$archive_log"

printf 'Archive created: %s\n' "$archive_file"
printf 'Archive log:     %s\n' "$archive_log"
