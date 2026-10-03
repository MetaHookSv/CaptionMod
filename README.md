# CaptionMod

[中文文档](README.zh-CN.md)

CaptionMod is a VGUI2-based subtitle, HUD-text translation and chat-dialog plugin for
MetaHookSv. It displays subtitles for sounds, sentences, HudText and SendAudio messages,
translates HUD/network messages through CSV dictionaries with regex support, adds
multi-byte character rendering to the legacy VGUI1 and HUD elements, and replaces the
chat dialog with a Source 2007 style one.

* It requires [VGUI2Extension](https://github.com/MetaHookSv/VGUI2Extension), which must
  be loaded before this plugin.
* It is not compatible with
  [BugFixedHL](https://github.com/tmp64/BugfixedHL-Rebased), which uses a different VGUI2
  component layout.

## Compatibility

|        Engine               |      |
|        ----                 | ---- |
| GoldSrc_blob   (3248~4554)  | √    |
| GoldSrc_legacy (4554~6153)  | √    |
| GoldSrc_new    (8684 ~)     | √    |
| SvEngine       (8832 ~)     | √    |
| GoldSrc_HL25   (>= 9884)    | √    |

## Quick start

Download `CaptionMod-windows-x86.7z` from
[GitHub Releases](https://github.com/MetaHookSv/CaptionMod/releases) (built on `v*` tag
pushes). Merge every extracted `<mod>/` directory into the matching mod directory and
enable CaptionMod in MetaHook's `metahook/configs/plugins.lst`, after
`VGUI2Extension.dll`. Don't forget to launch game from MetaHook.

## Documentation

- [Build instruction](docs/en/build-instruction.md)
- [Installation](docs/en/installation.md)
- [Features](docs/en/features.md)
- [CI/CD](docs/en/ci-cd.md)

## License

Licensed under the [MIT License](LICENSE).
