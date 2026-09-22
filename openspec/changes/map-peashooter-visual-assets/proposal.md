## Why

豌豆射手的视觉资源跨越植物定义、Reanimation、动态图片加载和 PAK 资源，缺少经过当前 GOTY 资源验证的定位会导致覆盖错误资源或误改 `main.pak`。本次先建立可复用的准确资源链，并用单个醒目部件验证 `assets/extension` 覆盖机制。

## What Changes

- 追踪 `SEED_PEASHOOTER` 到 `REANIM_PEASHOOTER`、实际 Reanimation 文件及全部图片依赖。
- 核对图片资源 ID、真实 PAK 路径、格式、尺寸和透明信息。
- 记录 `resources.xml`、动态图片解析、compiled reanim 与 `assets/extension` 的职责和优先级。
- 在 `assets/extension` 中只覆盖一个豌豆射手头部贴图，验证最小视觉替换链路。
- 建立并维护极简的 `PVZ_MOD_MAP.md` 定位表。
- 不进行完整换皮，不修改 `main.pak`，不修改其他植物或游戏逻辑。

## Capabilities

### New Capabilities

- `peashooter-visual-override`: 提供经过实际源码与 GOTY 资源验证的豌豆射手视觉资源定位，以及不改动原始 PAK 的单资源覆盖能力。

### Modified Capabilities

无。

## Impact

- 文档：新增 `PVZ_MOD_MAP.md` 和本 change 的调查、设计及任务 artifacts。
- 资源：新增一个 `assets/extension/reanim` 下的测试覆盖贴图。
- 运行环境：沿用 `DebugGOTY|x64` 构建输出；不改变原版 Steam 目录与仓库内的 `main.pak` 副本。
