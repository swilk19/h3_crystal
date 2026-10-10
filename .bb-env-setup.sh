#!/usr/bin/env bash
# bb worker-worktree setup: install the Crystal toolchain and shards, then build
# ext/h3/build/lib/libh3.a, which every spec links against. (The shard's
# postinstall hook only fires for consumers, not for this repo itself.)
set -euo pipefail
mise install
shards install
make -C ext
