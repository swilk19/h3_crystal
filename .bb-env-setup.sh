#!/usr/bin/env bash
# bb worker-worktree setup: install the Crystal toolchain and shards, then build
# ext/h3/build/lib/libh3.a, which every spec links against. (The shard's
# postinstall hook only fires for consumers, not for this repo itself.)
set -euo pipefail
mise install
# Activate the toolchain pinned in .mise.toml. `mise install` only downloads
# it; a plain shell still resolves `crystal` from PATH (often an older install).
eval "$(mise env -s bash)"
crystal --version
shards install
make -C ext
