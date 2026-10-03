---
title: captionmod-privatevars
type: note
permalink: captionmod/privatevars
---

# CaptionMod 私有符号清单

本清单来自 `src/privatefuncs.cpp`，是 CaptionMod 通过宿主 gamedata 契约解析的全部引擎/客户端私有符号。
manifest 侧对应 `scripts/manifests/captionmod.json`；解析辅助函数见 `src/plugins.h`
（`GamedataResolvePtr` / `GamedataResolvePtrIfAvailable` / `GamedataQueryStructMember`）。

## Engine（11 个引擎身份，`RealDllInfo.ImageBase`）

| 符号 | kind | 解析函数 |
| --- | --- | --- |
| `cl_time` | global | `Engine_FillAddress_GetClientTime` |
| `cl_oldtime` | global | `Engine_FillAddress_GetClientTime` |
| `cl_viewentity` | global | `Engine_FillAddress_CL_ViewEntityVars` |
| `listener_origin` | global | `Engine_FillAddress_ListenerOrigin` |
| `cszrawsentences` | global | `Engine_FillAddress_VOX_LookupString` |
| `rgpszrawsentence` | global | `Engine_FillAddress_VOX_LookupString` |
| `scr_drawloading` | global | `Engine_FillAddress_SCR_BeginLoadingPlaque` |
| `S_FindName` | function | `Engine_FillAddress_S_FindName` |
| `S_StartDynamicSound` | function | `Engine_FillAddress_S_StartDynamicSound` |
| `S_StartStaticSound` | function | `Engine_FillAddress_S_StartStaticSound` |
| `S_LoadSound` | function | `Engine_FillAddress_S_LoadSound` |
| `TextMessageParse` | function | `Engine_FillAddress_TextMessageParse` |
| `COM_ExplainDisconnection` | function | `Engine_FillAddress_COM_ExplainDisconnection` |
| `COM_ExtendedExplainDisconnection` | function | `Engine_FillAddress_COM_ExplainDisconnection` |
| `SequenceGetSentenceByIndex` | function | `Engine_FillAddress_SequenceGetSentenceByIndex` |

均为**必需**：缺失时 `Sys_Error` 终止，与已删除的扫描定位器 `Sig_FuncNotFound` / `Sig_VarNotFound` 策略一致。
`cl_time` / `cl_oldtime` 由 VGUI2Extension 也已消费（同一 module CRC64 身份）。

## Client — Sven Co-op 分支（仅 `svencoop-8948` / `svencoop-10257` 发布）

在 `g_pMetaHookAPI->GetClientFactory()("SCClientDLL001", 0)` 成立时解析；缺失即致命。

| 符号 | kind | 解析函数 |
| --- | --- | --- |
| `CClient_SoundEngine_m_pSoundEngine` | global | `Client_FillAddress_SCClient_SoundEngine` |
| `CClient_SoundEngine.m_iSentenceCount` | structMember | `Client_FillAddress_SCClient_SoundEngine_maxsentences` |
| `CClient_SoundEngine_LoadSoundList` | function | `Client_FillAddress_SCClient_SoundEngine_LoadSoundList` |
| `CClient_SoundEngine_PlayFMODSound` | function | `Client_FillAddress_SCClient_SoundEngine_PlayFMODSound` |
| `CClient_SoundEngine_LookupSoundBySentenceIndex` | function | `Client_FillAddress_SCClient_SoundEngine_LookupSoundBySentenceIndex` |
| `CClient_SoundEngine_LookupSoundBySample` | function | `Client_FillAddress_SCClient_SoundEngine_LookupSoundBySample` |
| `GetClientColor` | function | `Client_FillAddress_SCClient_GetClientColor` |
| `gViewPort` | global | `Client_FillAddress_SCClient_GameViewport_AllowedToPrintText` |
| `TeamFortressViewport_AllowedToPrintText` | function | 同上 |
| `TeamFortressViewport_IsScoreBoardVisible` | function | `Client_FillAddress_SCClient_GameViewport_IsScoreBoardVisible` |
| `WeaponsResource_SelectSlot` | function | `Client_FillAddress_SCClient_WeaponsResource_SelectSlot` |
| `gHUD` | global | `Client_FillAddress_SCClient_CHud_GetBorderSize` |
| `CHud_GetBorderSize` | function | 同上 |

关键语义：`CClient_SoundEngine_m_pSoundEngine` 是**惰性单例的宿主变量地址**，首次构造前值为 `nullptr`，
因此插件用 `SCClient_SoundEngine_GetInstance()` 容空读取，而不是把访问器当成普通 getter。
`CClient_SoundEngine.m_iSentenceCount` 是对象内偏移（`uint32_t`），不是绝对地址。

## Client — Counter-Strike 分支（`cstrike` / `czero` / `czeror` 游戏目录）

| 符号 | kind | 解析方式 | 覆盖 |
| --- | --- | --- | --- |
| `GetTextColor` | function | `GamedataResolvePtrIfAvailable`（可选探测） | 6 个快照有 windows 记录；10210 系列与 czeror 只有 linux 记录 |
| `GetClientColor` | function | `GamedataResolvePtrIfAvailable` | 全部 10 个 CS 家族快照 |
| `g_LocationColor` | global | `GamedataResolvePtr`（必需） | 仅 `cstrike-10210`、`czero-10210` |

`g_LocationColor` 只在 `!GetTextColor` 且非 `czeror` 时解析。可达集合恰为
`{cstrike-10210, czero-10210}`：czeror 两个符号都不发布，因此 `czeror` 守卫必须保留，
否则必需的 resolve 会让插件中止。

## 未纳入清单

- `CGameViewport` 无 catalog 记录，保留自身定位器。
- `S_Init`、`SCR_BeginLoadingPlaque`、`realtime`、`hostparam_basedir` 等已按
  「上游发布 ≠ 消费端需要」删除（无读取点）。
- `VOX_LookupString` 是插件内自带实现，只消费 `cszrawsentences` / `rgpszrawsentence` 两个计数器，
  本身不解析。
