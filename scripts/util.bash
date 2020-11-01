#! /bin/bash
# Utily functions for bash scripts

# Print error message to stdout
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

# Print error message and quit
abort() {
    err "$1"
    exit 1
}

