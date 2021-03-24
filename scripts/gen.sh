#!/usr/bin/env bash
set -euo pipefail

readonly script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

(

cd "$script_dir/.."

kdrfc -h3 draft-ietf-jsonpath-base.md && \
xmlstarlet sel -T -t -v '//sourcecode[@type="abnf"]' ./draft-ietf-jsonpath-base.xml 2>/dev/null \
| aex \
| tee draft-ietf-jsonpath-base.abnf \
| bap -S path -q
)
