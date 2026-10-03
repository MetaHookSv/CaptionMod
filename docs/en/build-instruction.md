[Back to README](../../README.md) | [中文](../zh-CN/build-instruction.md)

# Build instruction

This page covers the build and dependency details of the CaptionMod plugin.
For the install layout and enabling the plugin, see [Installation](installation.md);
for engine compatibility, features and console variables, see [Features](features.md).

CaptionMod is the Windows x86 CMake project for the MetaHook CaptionMod plugin.

CaptionMod's own public interface is the VGUI2Extension interface set in `include/Interface/`, taken from the VGUI2Extension repository and installed by this repository.

## Requirements

- Windows with Visual Studio 2022 C++ desktop workload and the Windows SDK
- CMake 3.21+
- Git
- Network access on first configure: CMake fetches MetaHook and VGUI2Extension via FetchContent, initializes the csv-parser submodule, and downloads, verifies and extracts VC-LTL 5.3.1

## Build

```bat
scripts\build-CaptionMod-x86-Debug.bat
scripts\build-CaptionMod-x86-Release.bat
```

Both entry points use `Visual Studio 17 2022 -A Win32` and perform configure, build and
install. They can be invoked from outside the project; when `SolutionDir` is unset the
project is located from the script path. Initialization, download, configure, compile or
install failure returns a non-zero exit code. Build directories are `build/x86/Debug`
and `build/x86/Release`. This project provides plain Debug and Release, no AVX2 entry point.

## Specifying source paths manually

MetaHook and VGUI2Extension are downloaded automatically at fixed versions. To reuse
local sources, pass any of these optional parameters:

| Parameter | Local source directory |
| --- | --- |
| `METAHOOK_SOURCE_PATH` | MetaHook repository root with `include/metahook.h` and the HLSDK, SourceSDK and VGUI sources |
| `VGUI2EXTENSION_SOURCE_PATH` | VGUI2Extension repository root with `include/Interface/IVGUI2Extension.h`, `IDpiManager.h` and the Input, Scheme and Surface extension interfaces under `include/Interface/VGUI` |

There are no SDL or Capstone include arguments: unlike the Renderer plugin, CaptionMod does
not consume those headers.

CaptionMod needs VGUI2Extension's public headers at build time. Its interface directories
take precedence over MetaHook's matching directories. `VGUI2Extension.dll` is a required
runtime plugin: CaptionMod fails fast when it is missing.

CaptionMod also consumes MetaHook's `resolve-game-symbol` gamedata API and therefore
requires a MetaHook build at API 114 or newer.

For example, using local sources for a Release build:

```bat
scripts\build-CaptionMod-x86-Release.bat ^
  "-DMETAHOOK_SOURCE_PATH=D:/MetaHook" ^
  "-DVGUI2EXTENSION_SOURCE_PATH=D:/VGUI2Extension"
```

Both paths also accept same-named environment variables on first configure.
Use `-DNAME=value` to change a cached value; `-DNAME=` restores automatic fetching.

## csv-parser

The dictionary parser is consumed as the `hzqst/csv-parser-fork` submodule at
`thirdparty/csv-parser-fork` (branch `MHSV`), matching the original project's
`CSVParserDirectory`, which is included as `<single_include/csv.hpp>`. CMake initializes
it during the first configure. This is the only submodule in this repository.

## gamedata

CaptionMod declares the engine/client private symbols it resolves (including
per-gameVersion conditional groups and module ownership) through
`scripts/manifests/captionmod.json`, using the same schema as MetaHook.

At build time `CAPTIONMOD_SYNC_GAMEDATA` (default `ON`) invokes `scripts/sync-gamedata.py`
to trim the upstream catalog to just those symbols and publish it to
`metahook/gamedata/captionmod/`, then `scripts/validate-gamedata.py` validates it against
the manifest.

The raw snapshot is cached persistently under `build/x86/<config>/gamedata-sync/` and
supports offline builds.

With `OFF`, only existing data is installed and nothing is downloaded. This nested
directory is merged by the host launcher's catalog loader.

## CI

LiveBuild and Release share `.github/actions/build-windows-x86/action.yml`. It clones
the `main` branches of MetaHook and VGUI2Extension beside CaptionMod, records both commit
SHAs, and passes `METAHOOK_SOURCE_PATH` and `VGUI2EXTENSION_SOURCE_PATH` explicitly.
Local builds without source paths continue to use pinned commits.

There is no automated regression test suite: the original project built this plugin with
MSBuild only, so verification is a clean build plus the gamedata manifest gate.
