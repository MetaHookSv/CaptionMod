[Back to README](../../README.md) | [中文](../zh-CN/ci-cd.md)

# CI/CD

Both workflows share `.github/actions/build-windows-x86/action.yml`.

## Triggers

| Workflow | Trigger | Output |
| --- | --- | --- |
| `livebuild.yml` | push / pull request / manual on `main` | `CaptionMod-windows-x86.7z` workflow artifact |
| `msbuild.yml` | push of a `v*` tag | `CaptionMod-windows-x86.7z` attached to a GitHub release |

## Steps

1. Clone the `main` branch of MetaHook and VGUI2Extension beside the runner workspace and
   record both commit SHAs. No submodules of MetaHook are initialized: CaptionMod does not
   consume SDL or Capstone headers.
2. Build and install with the Release entry point, passing `METAHOOK_SOURCE_PATH` and
   `VGUI2EXTENSION_SOURCE_PATH`.
3. Validate the installed `metahook/gamedata/captionmod` catalog against the manifest.
4. Package the installed `svencoop`, `svencoop_hidpi`, `gearbox`, `echoes` and
   `svencoop_schinese` directories into one `.7z`, then run `7z t`.

`upload-artifact` wraps files in ZIP unless `archive: false` is set, so LiveBuild uploads
the single `.7z` file directly to keep the raw 7z magic.

## Local equivalent

```bat
git clone --depth 1 --branch main https://github.com/MetaHookSv/MetaHook ../MetaHook
git clone --depth 1 --branch main https://github.com/MetaHookSv/VGUI2Extension ../VGUI2Extension
scripts\build-CaptionMod-x86-Release.bat ^
  "-DMETAHOOK_SOURCE_PATH=../MetaHook" ^
  "-DVGUI2EXTENSION_SOURCE_PATH=../VGUI2Extension"
python scripts\validate-gamedata.py install\x86\Release\svencoop\metahook\gamedata\captionmod --manifest scripts\manifests\captionmod.json
```
