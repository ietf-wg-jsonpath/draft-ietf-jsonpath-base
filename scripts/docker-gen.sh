#!/usr/bin/env bash
set -euo pipefail

readonly script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

(

cd "$script_dir/.."

docker build -t gen ./scripts
docker run --rm -v `pwd`:`pwd` gen `pwd`/scripts/gen.sh

)