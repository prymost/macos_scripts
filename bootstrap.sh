#!/usr/bin/env bash
set -uo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

${SCRIPT_DIR}/setup/initial.sh
${SCRIPT_DIR}/setup/configure_osx.sh
${SCRIPT_DIR}/setup/my_installs.sh
# ${SCRIPT_DIR}/setup/restore.sh
