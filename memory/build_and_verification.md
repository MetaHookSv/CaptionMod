---
title: build_and_verification
type: note
permalink: captionmod/build-and-verification
---

# CaptionMod CMake 迁移与验证

## 触发与范围

用户要求按 MetaHook 独立工程规则，把 MetaHookSv 的 CaptionMod 迁入独立仓库，支持 CMake，
并保持与已迁出的 Renderer / VGUI2Extension 仓库一致的约定、风格与契约。
基线为 MetaHookSv `fe80b6d60bfb487b52aed7ea7ec0492e7b27a5d2`。

## 原因与构建边界

原 `.vcxproj` 依赖 SolutionDir、`tools/global_common.props`（`CSVParserDirectory`、
`CapstoneIncludeDirectory`、`GLEWCheckRequirements`、`PluginPostBuildCommand`）和预先安装的
Capstone/GLEW 库，post-build 还会把 DLL 复制到本机游戏目录。独立工程使用显式源码清单和
CMake target 依赖，统一安装到 `install/x86/<configuration>/`。

- `cmake/Sources.cmake` 逐项保留原 vcxproj 的全部 120 个 `ClCompile` 项：106 个
  MetaHook SDK / VGUI 单元 + 14 个本插件单元。`MurmurHash2.cpp` 是**必需**的编译单元：`src/Viewport.h:145-146` 的
  `CTypedDictionaryHasher::operator()` 调用 `MurmurHash2(...)`。删掉它会在链接期失败
  （实测 `LNK2001`/`LNK1120`：unresolved external symbol `?MurmurHash2@@YAIPBXHI@Z`），
  因为本工程编译的 MetaHook / SourceSDK 源码里没有同名定义（已全量 grep 确认）。
- 原工程的 `vgui_internal.h`（`ClInclude`）在源仓库中已不存在，未迁入。
- MetaHook、VGUI2Extension 默认使用 FetchContent 获取固定提交，显式 `*_SOURCE_PATH`
  跳过对应获取。`hzqst/csv-parser-fork`（分支 `MHSV`，提交 `c393238`）是本仓库唯一 submodule，
  提供 `<single_include/csv.hpp>`，对应原 `CSVParserDirectory`；Capstone、GLEW、GLFW 是
  原 MSBuild 前置检查的遗留物，本插件不需要。
- 本工程不消费 SDL 或 Capstone 头文件，因此 Dependencies 不引入 `SDL*_INCLUDE_DIRS` /
  `CAPSTONE_INCLUDE_DIRS`，CI 也不初始化 MetaHook 的任何 submodule。
- `STEAM_API_NODLL` 是配置级定义，保留；未引入被 csproj 排除的 `include/SteamSDK` 目录，
  以免与 MetaHook SDK 的 `internal/steamsdk` 版本冲突。
- 语言标准取 **C++20**，与 Renderer / VGUI2Extension 一致（原 vcxproj 未指定标准）。
- 源码、方案、字典与本地化资源保持字节一致；旧 vcxproj / filters / `.vcxproj.user` /
  `.vscode` 不迁入。
- gamedata 查询/解析 API 由宿主 MetaHook 提供，CaptionMod 要求 API 114 及以上
  （`src/plugins.h` 的 `static_assert` 固化）。迁移不改变该契约。
- 运行资源保留原 mod 目录名安装：`assets/{svencoop,svencoop_hidpi,svencoop_schinese,gearbox,echoes}/`
  分别装到前缀根下的同名目录。这偏离了 Renderer/VGUI2Extension「把 `svencoop/` 合并到目标 mod」
  的文档措辞，但保证了 Echoes (`echoes/captionmod`)、Gearbox (`gearbox/captionmod`)、
  HiDPI (`svencoop_hidpi/captionmod`) 与简中地图字典的目标路径与源仓库一致；如统一成
  `assets/svencoop/...`，这些文件会被装到错误的 mod 目录。

## 本次实测（2026-10-03）

环境：Windows 11，Visual Studio 2022 Community，MSVC 19.44.35228.0，
Windows SDK 10.0.26100.0，CMake 3.31（VC-LTL 5.3.1 复用已缓存包）。
外部源码为同级仓库 `D:/MetaHookSv-org/MetaHook`（`ace5d9f7`）与
`D:/MetaHookSv-org/VGUI2Extension`（`834b7f7a`，工作区干净）。

| 验证 | 结果 |
| --- | --- |
| Release 配置（VS 17 2022 -A Win32，显式两个源码路径） | 退出 0 |
| Release 编译、链接、安装 | 退出 0，0 警告 |
| Debug 配置、编译、链接、安装 | 退出 0，3 条 pre-existing `C4101` 警告 |
| C++20 下 `clamp` 宏冲突 | `exportfuncs.cpp` 引入 `mathlib/mathlib.h` 的 `clamp` 宏与 C++20 `std::clamp` 冲突，导致 11 条 `algorithm` 头错误；在该文件 `#undef clamp` 后归零 |
| gamedata 同步 + 校验 | `validate-gamedata.py --manifest` 通过：21 个快照，engine 15 + Sven client 13 条/快照 |
| 裁剪结果 | cstrike-10210/czero-10210 各 2 条（`GetClientColor`+`g_LocationColor`）、其余 cstrike/czero 3 条、czeror 1 条、hl/cof 15 条、svencoop 28 条 |
| 安装布局 | `svencoop/captionmod` 18、`svencoop_hidpi/captionmod` 3、`gearbox/captionmod` 3、`echoes/captionmod` 4、`svencoop_schinese/maps` 324、plugins 2、gamedata 22 个文件 |
| DLL PE | Debug / Release 均为 x86 DLL（Machine 0x014c），导出 `CreateInterface`；Release 973,312 字节 |
| CRT | 两者均导入 `msvcrt.dll`（VC-LTL） |
| 生成工程设置 | 两配置 `LanguageStandard=stdcpp20`，Debug `MultiThreadedDebug` / Release `MultiThreaded`，包含 VC-LTL 目录，无 `D:/MetaHookSv` 引用 |
| 字节一致 | 26/27 源码文件与源仓库 blob 逐字节一致（仅 `exportfuncs.cpp` 为上述必需修正）；352 个运行资源工作文件逐字节一致 |
| `dictionary.csv` 换行 | 源仓库该文件的 blob 是 CRLF、工作区文件却是 LF（`git diff` 干净，属源仓库历史遗留）；新仓库按工作区实际内容（LF）入库，与插件在源 checkout 中读取的字节一致。`svencoop/captionmod/dictionary.csv` 因此是唯一 blob 与源仓库不同的资源，其余 351 个资源的 git blob 哈希完全一致 |
| 无效 `METAHOOK_SOURCE_PATH` | configure 阶段返回 1，提示 `include/metahook.h` 缺失 |
| 无效 `VGUI2EXTENSION_SOURCE_PATH` | configure 阶段返回 1，提示 `include/Interface/IVGUI2Extension.h` 缺失 |

## 复验与适用范围

- **未执行游戏验证。** 没有启动游戏、加载插件、创建 VGUI2 上下文，也没有验证字幕渲染、
  字典命中、聊天框或输入法行为。构建成功与 gamedata manifest 校验通过只能证明编译期契约；
  本仓库也没有原工程的自动化测试可迁入（原工程仅用 MSBuild 构建）。
- **CI 未在本机运行。** `.github/actions/build-windows-x86/action.yml` 与两个 workflow 未推送、
  未执行；其克隆、打包、7z 步骤只在本地配置阶段核对过参数。
- 固定提交与同级仓库当前 HEAD 的一致性（MetaHook `ace5d9f7`、VGUI2Extension `834b7f7a`）
  只在本次配置时成立；同级仓库随后可能前进。
- `MurmurHash2.cpp` / `MurmurHash2.h` 全部迁入且必须保留：`Viewport.h` 的
  `CTypedDictionaryHasher` 直接调用 `MurmurHash2`，删掉该 TU 会链接失败。它只实现了
  `MurmurHash2`（其余 `MurmurHash64A/64B/2A/Neutral2/Aligned2` 无调用点但与该函数同处一个
  公共领域源文件，未做裁剪）。
- 历史记录不属于本次证据：`gamedata-migration.md` 与 `CaptionMod.md` 中的地址、偏移与
  二进制等价性结论来自源仓库，不代表本仓库已复现。
