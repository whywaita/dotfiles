#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
dot_codex_dir="$(cd "$script_dir/.." && pwd)"

template_path="$dot_codex_dir/config.template.toml"
config_dir="$HOME/.codex"
config_path="$config_dir/config.toml"

mkdir -p "$config_dir"

TEMPLATE="$template_path" CONFIG="$config_path" python3 - <<'PY'
import json
import os
import sys
import re
from pathlib import Path

try:
    import tomllib  # Python 3.11+
except Exception:
    try:
        import tomli as tomllib  # type: ignore
    except Exception:
        tomllib = None

TEMPLATE = os.environ["TEMPLATE"]
CONFIG = os.environ["CONFIG"]

if tomllib is None:
    # Fallback: copy template over if TOML parser is unavailable.
    Path(CONFIG).write_text(Path(TEMPLATE).read_text(), encoding="utf-8")
    sys.exit(0)


def load_toml(path: str) -> dict:
    p = Path(path)
    if not p.exists():
        return {}
    return tomllib.loads(p.read_text(encoding="utf-8"))


def deep_merge(dst: dict, src: dict) -> dict:
    for k, v in src.items():
        if isinstance(v, dict) and isinstance(dst.get(k), dict):
            deep_merge(dst[k], v)
        else:
            dst[k] = v
    return dst


def key_needs_quote(key: str) -> bool:
    return re.match(r"^[A-Za-z0-9_-]+$", key) is None


def format_key(key: str) -> str:
    if key_needs_quote(key):
        return json.dumps(key)
    return key


def format_value(val) -> str:
    if isinstance(val, bool):
        return "true" if val else "false"
    if isinstance(val, (int, float)):
        return str(val)
    if isinstance(val, str):
        return json.dumps(val)
    if isinstance(val, list):
        return "[" + ", ".join(format_value(v) for v in val) + "]"
    raise TypeError(f"Unsupported value type: {type(val)}")


def write_tables(prefix, data, lines) -> None:
    scalar_items = {k: v for k, v in data.items() if not isinstance(v, dict)}
    dict_items = {k: v for k, v in data.items() if isinstance(v, dict)}

    if prefix and scalar_items:
        lines.append(f"[{prefix}]")
        for k in sorted(scalar_items.keys()):
            lines.append(f"{format_key(k)} = {format_value(scalar_items[k])}")
        lines.append("")

    for k in sorted(dict_items.keys()):
        sub = dict_items[k]
        sub_prefix = format_key(k) if prefix is None else f"{prefix}.{format_key(k)}"
        write_tables(sub_prefix, sub, lines)


def dumps_toml(data: dict) -> str:
    lines = []
    top_scalars = {k: v for k, v in data.items() if not isinstance(v, dict)}
    top_tables = {k: v for k, v in data.items() if isinstance(v, dict)}

    for k in sorted(top_scalars.keys()):
        lines.append(f"{format_key(k)} = {format_value(top_scalars[k])}")

    if top_scalars and top_tables:
        lines.append("")

    for k in sorted(top_tables.keys()):
        write_tables(format_key(k), top_tables[k], lines)

    # Ensure trailing newline
    return "\n".join(lines).rstrip() + "\n"


existing = load_toml(CONFIG)
template = load_toml(TEMPLATE)
merged = deep_merge(existing, template)

Path(CONFIG).write_text(dumps_toml(merged), encoding="utf-8")
PY
