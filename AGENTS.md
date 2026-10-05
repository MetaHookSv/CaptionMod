# AGENTS.md

This file provides guidance and important rules working with code in this repository.

## When coding / building plan

- Use a progressive disclosure approach for agent coding in this repository: start from high-level information in the Basic Memory knowledge base first, and only locate/read specific files or symbols when necessary, instead of expanding a large amount of context at once.

### Basic Memory knowledge base (project-scoped, `memory/`)

- Notes live in `memory/` (markdown with YAML frontmatter: `title`/`type`/`permalink`), tracked in git.
- Notes use the `captionmod/` permalink prefix to distinguish them from the source repository.

### High-level information in this repository (read corresponding notes first)

- Project overview, dependency boundaries and entry points: `project_overview`
- Plugin architecture, runtime resources and gamedata migration history: `CaptionMod`
- Engine/client private symbol inventory: `privatevars/captionmod-privatevars.md` (also `captionmod-privatevars`)
- Build commands, dependency pinning, gamedata sync, verification status: `build_and_verification`
- Coding conventions: `CodeStyles`

### When notes are insufficient: source entry points (query and read on demand)

- Build: `CMakeLists.txt`, `cmake/Sources.cmake` (explicit compile list), `cmake/Dependencies.cmake` (source-path resolution and FetchContent fallback), `cmake/VCLTL.cmake`, `scripts/build-CaptionMod-x86-{Debug,Release}.bat`
- Plugin sources: `src/`; lifecycle entry `src/plugins.cpp`, private symbol resolution `src/privatefuncs.cpp`, hook and HUD paths `src/exportfuncs.cpp`, subtitle viewport `src/Viewport.cpp`
- Public API / interface: the VGUI2Extension interface set in `include/Interface/` (`IVGUI2Extension.h`, `IDpiManager.h`, `VGUI/` for `IInput2.h`, `IScheme2.h`, `ISurface2.h`), taken from the VGUI2Extension repository, taking precedence over MetaHook's historical copies, and installed by this repository
- Runtime assets: `assets/svencoop/captionmod/` plus the `svencoop_hidpi`, `gearbox`, `echoes` and `svencoop_schinese` overlays, installed to the prefix root with their original per-mod directory names
- gamedata: `scripts/manifests/captionmod.json` (same schema as MetaHook), `scripts/sync-gamedata.py`, `scripts/validate-gamedata.py`; the build-time sync prunes the upstream catalog into the nested `metahook/gamedata/captionmod/` directory, which the host launcher merges
- External sources, read-only inputs: `METAHOOK_SOURCE_PATH` (public API, SourceSDK, VGUI) and `VGUI2EXTENSION_SOURCE_PATH` (public interface headers only; the plugin is not built here). Empty paths fall back to FetchContent (MetaHook tracks the latest `main`; VGUI2Extension uses a fixed commit); `thirdparty/csv-parser-fork` (branch `MHSV`) is the only submodule
- Docs: `README.md` / `README.zh-CN.md`, prose pages under `docs/en/` and `docs/zh-CN/`
- Build output: `build/x86/<configuration>/`; install output: `install/x86/<configuration>/`. Neither is tracked, and nothing is deployed to the game automatically.

## Repository rules

- Preserve the MetaHook API, plugin exports, calling conventions, VGUI2 callback contract and original behavior. Match the naming, indentation and comment style of the files you touch.
- Resolve engine and client private symbols through the host `ResolveGameSymbol`/gamedata contract. Do not add scan fallbacks for symbols gamedata already provides, and do not judge coverage across modules by symbol name alone.
- CaptionMod requires MetaHook API 114 or newer (`QueryGameSymbolStructMember`); `src/plugins.h` asserts this. At runtime `VGUI2Extension.dll` is required, not optional.
- When gamedata usage changes, update `scripts/manifests/captionmod.json` in the same change, including module ownership, per-gameVersion conditional groups and exemptions.
- Do not modify external sources or third-party sources, including the CSV parser submodule. VC-LTL comes from a hash-verified binary cache.
- This project has no automated regression test suite; verification is a clean Debug and Release build plus the gamedata manifest gate.
- Verification distinguishes a build from a real game run. Claims about subtitle rendering, IME/chat behavior or per-engine compatibility must not be made without real in-game evidence.
- Dictionary encoding matters: CSV dictionaries are UTF-8 BOM, localization `_%language%.txt` files are UTF-16 LE. Do not "normalize" them.
