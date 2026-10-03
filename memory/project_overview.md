---
title: project_overview
type: note
permalink: captionmod/project-overview
---

# CaptionMod 独立工程

## 范围与来源

本仓库迁入 MetaHookSv `fe80b6d60bfb487b52aed7ea7ec0492e7b27a5d2` 的 `Plugins/CaptionMod`
源码，以及 `Build/svencoop/captionmod`、`Build/svencoop_hidpi/captionmod`、
`Build/gearbox/captionmod`、`Build/echoes/captionmod` 运行资源，另含
`Build/svencoop_schinese/maps/*_dictionary.csv`（仅本插件读取的地图字幕翻译示例），
提供 Windows x86 Debug/Release CMake 构建。插件源码、方案、字典与本地化资源保留原样；
不迁入其他插件、宿主实现、旧 vcxproj / filters 或预编译依赖。

## 架构与入口

- `src/plugins.cpp`：MetaHook 插件生命周期、导出与 hook 安装。
- `src/privatefuncs.cpp`：引擎/客户端私有符号解析（全部走宿主 gamedata 契约）与 hook 表。
- `src/exportfuncs.cpp`：HUD 导出替换、音效/句子/TextMessage 路径与字典查询入口。
- `src/Viewport.cpp`、`src/SubtitlePanel.cpp`：顶点界面接入、字典加载与字幕面板渲染。
- `src/message.cpp`、`src/chatdialog.cpp`、`src/cstrikechatdialog.cpp`：HUD 消息翻译与聊天框。
- `src/VGUI2ExtensionImport.cpp`：VGUI2Extension 接口导入与回调注册。
- `src/GameUI.cpp`、`src/BaseUI.cpp`、`src/ClientVGUI.cpp`：GameUI / BaseUI / ClientVGUI 回调。
- `assets/svencoop/captionmod`：随 DLL 安装的方案、字典、本地化、素材与字体。
  `assets/svencoop_hidpi/captionmod`、`assets/gearbox/captionmod`、`assets/echoes/captionmod`
  为对应 mod 的覆盖层，`assets/svencoop_schinese/maps` 为地图字幕字典。
  每个 `assets/<mod>/` 目录装到前缀根下的同名目录，因此可直接递归复制进游戏的同名 mod 目录。

## 依赖边界

VGUI2Extension 的公共接口头文件由独立仓库提供：`VGUI2EXTENSION_SOURCE_PATH` 指向仓库根目录，
空值通过 FetchContent 获取固定提交。本仓库自带该接口集（`include/Interface/`，
优先于 MetaHook 的历史副本，并随 install 安装），只消费头文件，不构建 VGUI2Extension；
但运行时 `VGUI2Extension.dll` 是**必需**插件，缺失时 CaptionMod 快速失败。

MetaHook 提供公共 API、SourceSDK、VGUI 源码与 gamedata 查询 API，仅消费其源码，
不构建宿主可执行文件。指定 `METAHOOK_SOURCE_PATH` 时直接使用外部仓库根目录；
否则通过 FetchContent 获取固定提交，不使用 MetaHook submodule，也不初始化宿主的递归依赖。
CaptionMod 需要 gamedata API 114 及以上（`QueryGameSymbolStructMember`），代码中以
`static_assert` 固化该契约。本工程不消费 SDL 或 Capstone 头文件。

## 字典解析器

字典解析器 `hzqst/csv-parser-fork`（分支 `MHSV`）是本仓库唯一的 submodule，位于
`thirdparty/csv-parser-fork`，以 `<single_include/csv.hpp>` 引入，对应原工程的
`CSVParserDirectory`；CMake 首次配置自动初始化。

私有符号解析必须遵循宿主 gamedata 契约，不能为已发布的符号恢复扫描 fallback；
上游发布不等于消费端需要。迁移不改变导出、hook 调用约定、VGUI2 回调契约或资源格式。
gamedata 的 manifest 与同步说明见 [构建及验证](build_and_verification.md)，符号清单见
[captionmod-privatevars](captionmod-privatevars.md)。

## 知识入口

- [插件架构与私有符号清单](CaptionMod.md)
- [构建及验证](build_and_verification.md)
- [编码约定](CodeStyles.md)
- [使用、功能与依赖说明](../README.md)

Basic Memory 在本仓库注册为 `captionmod` 项目（见 `.mcp.json` 与 `.codex/config.toml`），
`metahooksv` 项目属于源仓库，只用于查阅来源。
