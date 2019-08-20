#!/bin/bash
#set -eoux pipefail

# shellcheck disable=SC2086
su - farcry2 -c "/opt/farcry2/bin/FarCry2_server" \
     "$@"

