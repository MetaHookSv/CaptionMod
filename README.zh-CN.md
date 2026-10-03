# CaptionMod

[English README](README.md)

CaptionMod 是 MetaHookSv 的 VGUI2 字幕 / HUD 文字翻译 / 聊天框插件。它为音效、句子、
HudText 和 SendAudio 消息显示字幕，用 CSV 字典（支持正则）动态翻译 HUD 与网络消息，
为旧版 VGUI1 与 HUD 元素加入多字节字符渲染，并用起源 2007 风格的聊天框替换原聊天框。

* 依赖 [VGUI2Extension](https://github.com/MetaHookSv/VGUI2Extension)，且必须先于本插件加载。
* 与 [BugFixedHL](https://github.com/tmp64/BugfixedHL-Rebased) 不兼容：它使用了不同的 VGUI2 对象布局。

## 兼容性

|        Engine               |      |
|        ----                 | ---- |
| GoldSrc_blob   (3248~4554)  | √    |
| GoldSrc_legacy (4554~6153)  | √    |
| GoldSrc_new    (8684 ~)     | √    |
| SvEngine       (8832 ~)     | √    |
| GoldSrc_HL25   (>= 9884)    | √    |

## 快速开始

从 [GitHub Release](https://github.com/MetaHookSv/CaptionMod/releases) 下载
`CaptionMod-windows-x86.7z`（推送 `v*` 标签时构建）。将解压出的各个 `<mod>/` 目录合并到
同名 mod 目录，在 MetaHook 的 `metahook/configs/plugins.lst` 中把 CaptionMod 放在
`VGUI2Extension.dll` 之后启用。最后，别忘了从 MetaHook 启动游戏。

## 文档

- [构建说明](docs/zh-CN/build-instruction.md)
- [安装说明](docs/zh-CN/installation.md)
- [功能说明](docs/zh-CN/features.md)
- [CI/CD](docs/zh-CN/ci-cd.md)

## 许可证

项目采用 [MIT License](LICENSE)。
