# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Crystal language bindings for Uber's H3 hexagonal spatial indexing library. Currently wraps H3 C v3.6.0 via Crystal's FFI (`lib` declarations), with a migration to H3 v4.4.1 in progress. The H3 C source is bundled in `ext/`.

## Tooling

- **mise** manages the Crystal version (`.mise.toml`). Run `mise install` to set up.
- Crystal >= 1.10.0 required (`shard.yml` constraint)

## Build & Development Commands

```bash
mise install                      # Install Crystal version from .mise.toml
shards install                    # Install deps + build C library (postinstall hook runs make -C ext)
make -C ext                       # Rebuild just the C extension
crystal spec --verbose            # Run all tests
crystal tool format --check       # Check formatting (CI uses this)
crystal tool format               # Auto-format code
```

## Architecture

The library exposes a single `H3` module that extends four functional modules, each wrapping a category of H3 C functions:

- **Indexing** (`src/h3/indexing.cr`) — coordinate-to-H3 conversions (`geo_to_h3`, `h3_to_geo`, `h3_to_boundary`)
- **Inspection** (`src/h3/inspection.cr`) — validation and properties (`valid?`, `pentagon?`, `resolution`, `to_string`)
- **Traversal** (`src/h3/traversal.cr`) — neighbors and paths (`k_ring`, `hex_range`, `line`, `distance`)
- **Hierarchy** (`src/h3/hierarchy.cr`) — parent/child operations (`parent`, `children`, `compact`, `uncompact`)

Supporting layers:
- `src/h3/bindings/lib_h3.cr` — raw C FFI declarations with static linking (`@[Link(ldflags: "...libh3.a -lm")]`)
- `src/h3/bindings/types.cr` — `Resolution` class (validates 0–15 range, implements `to_unsafe` for C interop)
- `src/h3/bindings/base.cr` — base module setup; also includes `Miscellaneous` which provides utility functions shared across all modules

All public methods are called as `H3.method_name`.

## Consumer Usage

Downstream projects add this shard to their `shard.yml` and `require "h3_crystal/h3"`. The C library is statically linked — no system-level H3 install needed.

## Testing

Tests are in `spec/h3/` organized to mirror the module structure. They use Crystal's built-in Spec framework with `describe`/`it` blocks and `.should` assertions. The shared test index is `H3_VALID_INDEX = 612933930963697663` defined in `spec/spec_helper.cr`.

## Key Patterns

- Geo coordinates are converted between degrees (Crystal API) and radians (C API) at the binding boundary
- C arrays are allocated with `Pointer.malloc` and read back with `read_array_of_uint64`/`read_array_of_int32` helpers

## Versioning

Shard version tracks H3 C library compatibility: `<h3_major>.<h3_minor>.<our_patch>`. For example, `4.4.0` targets H3 v4.4, and `4.4.1` is a bugfix to the bindings against the same H3 version.
