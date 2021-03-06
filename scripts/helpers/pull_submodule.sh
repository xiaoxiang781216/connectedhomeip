#!/usr/bin/env bash

#
# Copyright (c) 2020 Project CHIP Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

CHIP_ROOT="$(dirname "$0")/../.."

if [[ -z "$name" || -z "$toplevel" ]]; then
    echo >&2 "This script should be run via update_submodules.sh"
    exit 1
fi

get_submodule_config() {
    git config --file "$toplevel/.gitmodules" "submodule.$name.$1"
}

set_submodule_config() {
    git config --file "$toplevel/.gitmodules" "submodule.$name.$1" "$2"
}

SUBMODULE_URL=$(get_submodule_config url)
SUBMODULE_BRANCH=$(get_submodule_config branch)
SUBMODULE_PATH=$(get_submodule_config path)

git fetch --quiet "$SUBMODULE_URL" "$SUBMODULE_BRANCH"

REPOS_COMMIT=$(get_submodule_config commit)
HEAD_COMMIT=$(git -C "$toplevel" rev-parse HEAD:"$SUBMODULE_PATH")
FETCH_COMMIT="$(git rev-parse FETCH_HEAD)"

if [[ "$HEAD_COMMIT" == "$FETCH_COMMIT" && "$REPOS_COMMIT" == "$FETCH_COMMIT" ]]; then
    exit 0
fi

git checkout --quiet "$FETCH_COMMIT"
git -C "$toplevel" add "$SUBMODULE_PATH"
set_submodule_config commit "$FETCH_COMMIT"

echo "    git -C $SUBMODULE_PATH log $(git rev-parse --short "$HEAD_COMMIT")..$(git rev-parse --short "$FETCH_COMMIT")"
