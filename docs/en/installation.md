[Back to README](../../README.md) | [中文](../zh-CN/installation.md)

# Installation

`install/x86/<Debug|Release>/`:

```text
svencoop/
  metahook/plugins/CaptionMod.dll
  metahook/plugins/CaptionMod.pdb
  metahook/gamedata/captionmod/    (CaptionMod's own gamedata json)
  captionmod/                      (schemes, dictionaries, localization, materials and fonts)
svencoop_hidpi/
  captionmod/                      (high-DPI scheme and dialog layouts)
gearbox/
  captionmod/                      (Opposing Force / Blue Shift overlay)
echoes/
  captionmod/                      (Echoes overlay)
svencoop_schinese/
  maps/                            (*_dictionary.csv map translation examples)
```

Merge each `svencoop*`, `gearbox` or `echoes` directory into the mod directory of the same
name (for example `svencoop`, `svencoop_hidpi`, `svencoop_schinese`, `gearbox`, `echoes`),
then enable `CaptionMod.dll` **after** `VGUI2Extension.dll` in MetaHook's
`metahook/configs/plugins.lst`.

CaptionMod requires `VGUI2Extension.dll` at runtime and fails fast when it is absent.

Then you can launch the game through MetaHook. i.e. `MetaHook.exe -game <mod>`.
