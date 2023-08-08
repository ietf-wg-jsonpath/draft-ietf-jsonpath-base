#!/usr/bin/env bash
set -euo pipefail

readonly script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

(

cd "$script_dir/.."

kdrfc -h3 draft-ietf-jsonpath-base.md && \
    make sourcecode && \
    bap -S path -q sourcecode/abnf/jsonpath_collected_abnf && \
    bap -S path -q sourcecode/abnf/normalized_path_collected_abnf
)
