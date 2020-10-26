#!/usr/bin/env bash
set -euo pipefail

readonly script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

(

cd "$script_dir/.."

xml2rfc ./draft-normington-jsonpath-latest.xml --text --html && \
aex draft-normington-jsonpath-latest.txt \
| grep -v "lower =" \
| grep -v "upper =" \
| grep -v "i =" \
| grep -v "step =" \
| grep -v "step &gt;=" \
| grep -v "start =" \
| grep -v "end =" \
| bap -S path -q && cp draft-normington-jsonpath-latest.html docs/index.html
# TODO fix aex to not extract ABNF-looking rules from pseudocode blocks
)
