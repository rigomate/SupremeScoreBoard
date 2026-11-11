#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

python3 - "$project_dir" <<'PY'
from pathlib import Path
import shutil
import sys

project = Path(sys.argv[1])
destination = project / 'release' / 'SupremeScoreBoard2' / 'SupremeScoreBoard2'
files = [Path(name) for name in (
    'mod_info.lua', 'mod_icon.png', 'README.md', 'notes.txt', 'runUnitTests.sh',
)]
for directory, extensions in {
    'hook': {'.lua', '.blua'},
    'modules': {'.lua', '.blua'},
    'textures': {'.dds', '.lua'},
    'previews': {'.jpg'},
    'unittest': {'.lua'},
}.items():
    files.extend(
        path.relative_to(project)
        for path in sorted((project / directory).rglob('*'))
        if path.is_file() and path.suffix in extensions
    )

# Check inputs before replacing a previous build. Only the inner mod folder
# belongs to this script; other files in release/ are left alone.
for relative in files:
    if not (project / relative).is_file():
        raise SystemExit(f'Missing release input: {relative}')
if destination.exists():
    shutil.rmtree(destination)
for relative in files:
    target = destination / relative
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(project / relative, target)

print(f'Packaged {len(files)} files into {destination}')
print('For the FAF upload, select this inner SupremeScoreBoard2 folder.')
PY
