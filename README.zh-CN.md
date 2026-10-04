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

## F5 调试（可选）

先安装 MetaHook，并在游戏的 `plugins.lst` 中启用本插件，然后配置独立的 Visual Studio Win32 解决方案：

```powershell
cmake -S . -B build/launch -G "Visual Studio 17 2022" -A Win32 -DMETAHOOKSV_ENABLE_LAUNCH_GAME=ON
```

打开解决方案，选择 **LaunchGame** 后按 **F5**。**DeployGame** 编译本插件及依赖，暂存 Install，再复制插件 DLL、PDB 和资源，最后由原生调试器启动已有游戏 launcher。不会修改根目录启动器/运行库或插件列表。VS 应开启运行前构建，并将构建失败策略设为 **不启动**；重新部署前请退出游戏。普通构建不会部署。

`METAHOOKSV_GAME_DIRECTORY` 默认通过 Steam 自动查找，`METAHOOKSV_GAME_APPID` 默认为 `225840`。自定义 mod 使用 `METAHOOKSV_GAME_MOD`，附加参数使用 `METAHOOKSV_GAME_ARGUMENTS`；支持 Debug 和 Release。

共享模块依次从 `METAHOOKSV_LAUNCH_GAME_MODULE_DIR`、所在 MetaHookSv 聚合仓库或固定提交的源码包获取。缺少 Installer 源码时自动下载 GitHub `latest` 的自包含 CLI，无需安装 .NET；可用 `METAHOOKSV_INSTALLER_RELEASE` 固定 tag，或用 `METAHOOKSV_INSTALLER_CLI_EXECUTABLE` 指定离线 EXE。插件模式要求 v20261004c 或之后版本。`build/launch/launch-game/installer/<release>` 下的有效缓存直接复用，不自动升级；切换 tag 或清理该私有缓存后重新下载。首次下载若触发 GitHub API 限流，可通过环境变量 `GH_TOKEN`/`GITHUB_TOKEN` 提供凭据。功能默认 OFF，关闭时不新增下载。

## 许可证

项目采用 [MIT License](LICENSE)。
