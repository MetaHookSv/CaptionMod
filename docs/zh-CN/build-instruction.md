[返回 README](../../README.md) | [English](../en/build-instruction.md)

# 构建说明

本页涵盖 CaptionMod 插件的构建与依赖细节。安装目录布局与启用插件见[安装说明](installation.md)；引擎兼容性、功能特性和控制台参数见[功能说明](features.md)。

CaptionMod 是 MetaHook CaptionMod 插件的 Windows x86 CMake 工程。

CaptionMod 自身使用的公共接口是 `include/Interface/` 下的 VGUI2Extension 接口集，取自 VGUI2Extension 仓库，由本仓库随 install 安装。

## 依赖要求

- Windows、Visual Studio 2022 的 C++ 桌面开发工具和 Windows SDK
- CMake 3.21+
- Git
- 首次配置需要网络：CMake 通过 FetchContent 获取 MetaHook 和 VGUI2Extension，初始化 csv-parser submodule，并下载、校验和解压 VC-LTL 5.3.1

## 构建

```bat
scripts\build-CaptionMod-x86-Debug.bat
scripts\build-CaptionMod-x86-Release.bat
```

两个入口均使用 `Visual Studio 17 2022 -A Win32`，执行 configure、build 和 install。
可从工程外调用；未设置 `SolutionDir` 时由脚本位置定位工程。初始化、下载、配置、编译或安装
失败返回非零退出码。构建目录为 `build/x86/Debug` 和 `build/x86/Release`。
本工程提供普通 Debug、Release，不提供 AVX2 入口。

## 手动指定源码路径

MetaHook 和 VGUI2Extension 默认自动下载固定版本。需要复用本地源码时，可按需传入以下可选参数：

| 参数 | 本地源码目录 |
| --- | --- |
| `METAHOOK_SOURCE_PATH` | MetaHook 仓库根目录，包含 `include/metahook.h` 及 HLSDK、SourceSDK、VGUI 源码 |
| `VGUI2EXTENSION_SOURCE_PATH` | VGUI2Extension 仓库根目录，包含 `include/Interface/IVGUI2Extension.h`、`IDpiManager.h` 及 `include/Interface/VGUI` 下的 Input、Scheme、Surface 扩展接口 |

本工程没有 SDL / Capstone include 参数：与 Renderer 不同，CaptionMod 不消费这些头文件。

CaptionMod 编译时需要 VGUI2Extension 的公共头文件，其接口目录优先于 MetaHook 的同名目录。
`VGUI2Extension.dll` 是必需的运行时插件：缺失时 CaptionMod 会快速失败。

CaptionMod 还消费 MetaHook 的 `resolve-game-symbol` gamedata API，因此要求 MetaHook 达到 API 114 或更高。

例如，使用本地源码构建 Release：

```bat
scripts\build-CaptionMod-x86-Release.bat ^
  "-DMETAHOOK_SOURCE_PATH=D:/MetaHook" ^
  "-DVGUI2EXTENSION_SOURCE_PATH=D:/VGUI2Extension"
```

以上路径也可在首次配置时通过同名环境变量设置。修改已缓存的值请使用 `-D参数名=值`；
将源码路径设为空值（`-D参数名=`）可恢复自动获取。

## csv-parser

字典解析器以 `hzqst/csv-parser-fork` submodule 形式使用，位于
`thirdparty/csv-parser-fork`（分支 `MHSV`），对应原工程的 `CSVParserDirectory`，
以 `<single_include/csv.hpp>` 引入。CMake 首次配置时自动初始化。
这是本仓库唯一的 submodule。

## gamedata

CaptionMod 通过 `scripts/manifests/captionmod.json`（与 MetaHook 同一 schema）声明它解析的引擎/客户端私有符号（含按 gameVersion 生效的条件组与 module 归属）。

构建时 `CAPTIONMOD_SYNC_GAMEDATA`（默认 `ON`）调用 `scripts/sync-gamedata.py`，把上游 catalog 裁剪为仅含这些符号并发布到 `metahook/gamedata/captionmod/`，随后 `scripts/validate-gamedata.py` 按 manifest 校验。

原始快照持久缓存在 `build/x86/<config>/gamedata-sync/` 并支持离线构建。

`OFF` 时只安装已有数据，不下载。该嵌套目录被宿主 launcher 的 catalog 加载器合并。

## CI

LiveBuild 和 Release 共用 `.github/actions/build-windows-x86/action.yml`，在 CaptionMod
同级目录克隆 MetaHook 和 VGUI2Extension 的 `main` 分支，记录各自的提交 SHA，并显式传入
`METAHOOK_SOURCE_PATH` 和 `VGUI2EXTENSION_SOURCE_PATH`。本地未指定源码路径时仍使用固定提交。

本工程没有自动化回归测试：原工程仅用 MSBuild 构建该插件，验证方式是干净构建加上 gamedata manifest 门禁。
