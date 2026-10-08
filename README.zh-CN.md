# CaptionMod

[English README](README.md)

CaptionMod 是 MetaHookSv 的 VGUI2 字幕 / HUD 文字翻译 / 聊天框插件。它为音效、句子、
HudText 和 SendAudio 消息显示字幕，用 CSV 字典（支持正则）动态翻译 HUD 与网络消息，
为旧版 VGUI1 与 HUD 元素加入多字节字符渲染，并用起源 2007 风格的聊天框替换原聊天框。

* 依赖 [VGUI2Extension](https://github.com/MetaHookSv/VGUI2Extension)，且必须先于本插件加载。
* 与 [BugFixedHL](https://github.com/tmp64/BugfixedHL-Rebased) 不兼容：BugFixedHL使用了不同的 VGUI2 对象布局。

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
- [F5 调试（可选）](docs/zh-CN/debugging.md)

## 许可证

项目采用 [MIT License](LICENSE)。

## C/C++ 格式化

使用 [MetaHookSv/FormatValidation](https://github.com/MetaHookSv/FormatValidation)
共享工具及固定版本 **clang-format 23.1.3**，采用 DiligentCore 风格（4 空格，保留
include 顺序）。为 CMake 使用的 Python 解释器安装格式工具：

```sh
python -m pip install clang-format==23.1.3
cmake -S . -B build/format "-DFORMAT_VALIDATION_ONLY=ON"
cmake --build build/format --target format-check
cmake --build build/format --target format
```

格式专用配置需要 CMake 3.21+、Git、Python 3.9+（CI 使用 3.12）及构建生成器；
使用 `-G Ninja` 可无需 Visual Studio。它不准备原生 SDK 或游戏依赖。
格式目标需显式执行，不加入普通 DLL 构建。使用 Visual Studio 生成器时，执行目标
需追加 `--config Debug` 或 `--config Release`。

聚合仓库注入 `FORMAT_VALIDATION_SOURCE_PATH=thirdparty/FormatValidation`。
独立组件支持该 CMake 参数及同名环境变量；为空时通过 FetchContent 获取固定工具
提交。相对路径应加引号，例如
`"-DFORMAT_VALIDATION_SOURCE_PATH=../../thirdparty/FormatValidation"`。
配置时在仓库根目录生成被 gitignore 的 `.clang-format` 供编辑器使用；格式规则应
在共享仓库修改，不修改生成副本。可通过 `FORMAT_VALIDATION_CLANG_FORMAT_EXECUTABLE`
指定工具路径，但版本仍须与固定版本一致。

检查覆盖 `src/`、`include/`、`tests/` 中维护的 C/C++ 文件，包括未被 Git 忽略的新文件。
相对仓库根目录的排除规则位于 `.clang-format-ignore`；第三方源和构建产物不纳入检查。
`clang-format` workflow 在 push、pull request 和手动运行时执行全量检查。
