[返回 README](../../README.md) | [English](../en/ci-cd.md)

# CI/CD

两个 workflow 共用 `.github/actions/build-windows-x86/action.yml`。

## 触发条件

| Workflow | 触发 | 产物 |
| --- | --- | --- |
| `livebuild.yml` | `main` 的 push / pull request / 手动触发 | `CaptionMod-windows-x86.7z` workflow artifact |
| `msbuild.yml` | 推送 `v*` 标签 | `CaptionMod-windows-x86.7z` 附到 GitHub Release |

## 步骤

1. 在 runner workspace 同级克隆 MetaHook 和 VGUI2Extension 的 `main` 分支，记录各自提交 SHA。
   不初始化 MetaHook 的任何 submodule：CaptionMod 不消费 SDL 或 Capstone 头文件。
2. 用 Release 入口构建并安装，显式传入 `METAHOOK_SOURCE_PATH` 和 `VGUI2EXTENSION_SOURCE_PATH`。
3. 按 manifest 校验安装后的 `metahook/gamedata/captionmod` catalog。
4. 把安装出的 `svencoop`、`svencoop_hidpi`、`gearbox`、`echoes`、`svencoop_schinese`
   打成一个 `.7z`，并执行 `7z t`。

`upload-artifact` 默认会用 ZIP 封装，因此 LiveBuild 使用 `archive: false` 直接上传单个
`.7z` 文件，保留原始 7z magic。

## 本地等效流程

```bat
git clone --depth 1 --branch main https://github.com/MetaHookSv/MetaHook ../MetaHook
git clone --depth 1 --branch main https://github.com/MetaHookSv/VGUI2Extension ../VGUI2Extension
scripts\build-CaptionMod-x86-Release.bat ^
  "-DMETAHOOK_SOURCE_PATH=../MetaHook" ^
  "-DVGUI2EXTENSION_SOURCE_PATH=../VGUI2Extension"
python scripts\validate-gamedata.py install\x86\Release\svencoop\metahook\gamedata\captionmod --manifest scripts\manifests\captionmod.json
```
