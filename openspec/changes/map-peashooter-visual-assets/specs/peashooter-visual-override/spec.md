## Purpose

建立一条可由当前 StableDecompile 源码和已复制 GOTY 资源重复核验的豌豆射手视觉资源链，并在不修改原始 `main.pak` 和游戏逻辑的前提下，用单一图片覆盖验证 `assets/extension` 资源通路。

## ADDED Requirements

### Requirement: 可核验的视觉依赖映射

系统 SHALL 只记录由当前源码、当前 GOTY `main.pak` 和其实际 Reanimation 内容确认的 `SEED_PEASHOOTER` 视觉依赖。

#### Scenario: 从植物类型追踪到图片

- **WHEN** 查看豌豆射手的资源映射
- **THEN** 结果包含 `SEED_PEASHOOTER -> REANIM_PEASHOOTER -> reanim/PeaShooterSingle.reanim -> IMAGE_REANIM_* -> reanim/*.png` 的实测链路

### Requirement: 完整换皮素材清单

系统 SHALL 为 `PeaShooterSingle.reanim` 实际引用的每个图片记录资源 ID、文件路径、用途、尺寸、格式、透明信息及是否属于独立动画部件。

#### Scenario: 准备完整 Reanimation 外观替换

- **WHEN** MOD 作者查看豌豆射完整换皮要求
- **THEN** 清单精确列出当前 Reanimation 的全部 13 个图片依赖，且将共享投射物和阴影标记为 Reanimation 之外的可选范围

### Requirement: 非破坏性单资源覆盖

系统 SHALL 通过 `assets/extension` 中与实际基础资源同路径同文件名的一张图片，覆盖一个易观察的豌豆射手部件，且 MUST NOT 修改任何 `main.pak` 或其他游戏逻辑。

#### Scenario: DebugGOTY x64 加载头部测试图

- **WHEN** 使用 `DebugGOTY|x64` 构建并启动游戏
- **THEN** `extension/reanim/PeaShooter_Head.png` 存在于运行目录，游戏不因该覆盖立即崩溃，且原始 PAK 保持不变
