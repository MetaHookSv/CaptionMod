[返回 README](../../README.md) | [English](../en/installation.md)

# 安装说明

`install/x86/<Debug|Release>/`：

```text
svencoop/
  metahook/plugins/CaptionMod.dll
  metahook/plugins/CaptionMod.pdb
  metahook/gamedata/captionmod/    (CaptionMod 自己的 gamedata json)
  captionmod/                      (方案、字典、本地化、素材与字体)
svencoop_hidpi/
  captionmod/                      (高 DPI 方案与对话框布局)
gearbox/
  captionmod/                      (Opposing Force / Blue Shift 覆盖层)
echoes/
  captionmod/                      (Echoes 覆盖层)
svencoop_schinese/
  maps/                            (*_dictionary.csv 地图翻译示例)
```

将 `svencoop*`、`gearbox`、`echoes` 各目录合并到同名的 mod 目录
（如 `svencoop`、`svencoop_hidpi`、`svencoop_schinese`、`gearbox`、`echoes`），
然后在 MetaHook 的 `metahook/configs/plugins.lst` 中，把 `CaptionMod.dll` 放在
`VGUI2Extension.dll` **之后**启用。

CaptionMod 运行时依赖 `VGUI2Extension.dll`，缺失时会快速失败。

然后你就可以从 MetaHook 启动游戏了。比如： `MetaHook.exe -game <mod>`。
