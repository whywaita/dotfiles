#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"

"$script_dir/codex-update-config.sh"
"$script_dir/codex-link-skills.sh"
