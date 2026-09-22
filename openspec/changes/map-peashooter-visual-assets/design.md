## Context

`gPlantDefs` 将 `SEED_PEASHOOTER` 映射到 `REANIM_PEASHOOTER`；`gLawnReanimationArray` 再将其注册为 `reanim/PeaShooterSingle.reanim`。GOTY `main.pak` 内同时存在该 Reanimation 源文件、compiled 文件及其 13 张实际引用图片。

基础 `properties/resources.xml` 不逐项注册这些 `IMAGE_REANIM_*` ID。`DefinitionLoadImage` 通过 `gDefLoadResPaths` 将 `IMAGE_REANIM_` 后缀按 `reanim/` 、`images/` 路径动态解析，并按 resourcepack、extension、dependency、base 的顺序查找。

## Goals / Non-Goals

**Goals:**

- 确认完整的豌豆射手 Reanimation 图片依赖。
- 用一个醒目的头部图片证明 extension 覆盖链路。
- 保留可长期维护的极简定位表。

**Non-goals:**

- 不执行完整换皮。
- 不替换共享投射物、投射物阴影或植物阴影。
- 不改动游戏逻辑、项目工具集或原始 PAK。

## Decisions

### 使用单图片动态覆盖

验证资源选择 `IMAGE_REANIM_PEASHOOTER_HEAD`，对应 `anim_face` 轨道和 `reanim/PeaShooter_Head.png`。该部件面积大、颜色明显且与其他图层独立。覆盖文件位于 `assets/extension/reanim/PeaShooter_Head.png`，尺寸保持 70×65 RGBA PNG，仅将头部绿色改为鲜明紫红色。

这种图片覆盖不需要新的 `resources.xml` 条目，也不需要替换 `.reanim` 或 `.reanim.compiled`；只有修改 Reanimation 结构时才需要 extension 下的源 Reanimation 和对应 compiled 文件。

### 实测的 Reanimation 素材清单

| 资源 ID | PAK 内文件 | 轨道 / 用途 | 尺寸 | PNG 存储 | 透明 | 独立部件 |
|---|---|---|---:|---|---|---|
| `IMAGE_REANIM_ANIM_SPROUT` | `reanim/anim_sprout.png` | `anim_sprout`，发芽部件（通用 ID，可能被其他动画共享） | 18×14 | Indexed + tRNS | 是 | 是 |
| `IMAGE_REANIM_PEASHOOTER_BACKLEAF` | `reanim/PeaShooter_backleaf.png` | `backleaf`，后叶主体 | 44×22 | RGBA | 是 | 是 |
| `IMAGE_REANIM_PEASHOOTER_BACKLEAF_LEFTTIP` | `reanim/PeaShooter_backleaf_lefttip.png` | `backleaf_left_tip`，后叶左尖 | 15×12 | Indexed + tRNS | 是 | 是 |
| `IMAGE_REANIM_PEASHOOTER_BACKLEAF_RIGHTTIP` | `reanim/PeaShooter_backleaf_righttip.png` | `backleaf_right_tip`，后叶右尖 | 12×10 | Indexed + tRNS | 是 | 是 |
| `IMAGE_REANIM_PEASHOOTER_BLINK1` | `reanim/PeaShooter_blink1.png` | `anim_blink` / `idle_shoot_blink`，眨眼帧 1 | 28×23 | RGBA | 是 | 是，被两轨道共享 |
| `IMAGE_REANIM_PEASHOOTER_BLINK2` | `reanim/PeaShooter_blink2.png` | `anim_blink` / `idle_shoot_blink`，眨眼帧 2 | 28×23 | RGBA | 是 | 是，被两轨道共享 |
| `IMAGE_REANIM_PEASHOOTER_FRONTLEAF` | `reanim/PeaShooter_frontleaf.png` | `frontleaf`，前叶主体 | 67×40 | RGBA | 是 | 是 |
| `IMAGE_REANIM_PEASHOOTER_FRONTLEAF_LEFTTIP` | `reanim/PeaShooter_frontleaf_lefttip.png` | `frontleaf_tip_left`，前叶左尖 | 22×29 | RGBA | 是 | 是 |
| `IMAGE_REANIM_PEASHOOTER_FRONTLEAF_RIGHTTIP` | `reanim/PeaShooter_frontleaf_righttip.png` | `frontleaf_right_tip`，前叶右尖 | 15×31 | RGBA | 是 | 是 |
| `IMAGE_REANIM_PEASHOOTER_HEAD` | `reanim/PeaShooter_Head.png` | `anim_face`，头部 / 脸 | 70×65 | RGBA | 是 | 是 |
| `IMAGE_REANIM_PEASHOOTER_MOUTH` | `reanim/PeaShooter_mouth.png` | `idle_mouth`，嘴部 | 35×49 | RGBA | 是 | 是 |
| `IMAGE_REANIM_PEASHOOTER_STALK_BOTTOM` | `reanim/PeaShooter_stalk_bottom.png` | `stalk_bottom`，茎下段 | 15×19 | Indexed + tRNS | 是 | 是 |
| `IMAGE_REANIM_PEASHOOTER_STALK_TOP` | `reanim/PeaShooter_stalk_top.png` | `stalk_top`，茎上段 | 26×17 | Indexed + tRNS | 是 | 是 |

### Reanimation 之外的共享视觉资源

`properties/resources.xml` 显式注册 `PROJECTILEPEA`、`PEA_SHADOWS`、`PLANTSHADOW` 和 `PLANTSHADOW2`。源码确认豌豆射手发射 `PROJECTILE_PEA`，渲染使用 `IMAGE_PROJECTILEPEA` 与 `IMAGE_PEA_SHADOWS`；植物阴影则与其他植物共享。它们不是 `PeaShooterSingle.reanim` 的图片依赖，因此不纳入本次单资源验证。

| 资源 ID | PAK 内文件 | 尺寸 | 范围 |
|---|---|---:|---|
| `IMAGE_PROJECTILEPEA` | `images/ProjectilePea.png` | 28×28 RGBA | 共享豌豆投射物 |
| `IMAGE_PEA_SHADOWS` | `images/pea_shadows.png` | 42×9 RGBA | 共享投射物阴影图集 |
| `IMAGE_PLANTSHADOW` | `images/plantshadow.png` | 86×36 RGBA | 共享植物阴影 |
| `IMAGE_PLANTSHADOW2` | `images/plantshadow2.png` | 86×36 RGBA | 共享备用植物阴影 |

## Resource Responsibilities

- `Lawn/Plant.cpp`: 植物类型、Reanimation 类型及运行时身体/头部动画实例的映射。
- `Sexy.TodLib/Reanimator.cpp`: Reanimation 枚举到 `.reanim` 路径的注册。
- `.reanim`: 定义轨道、变换、时序及图片 ID 引用。
- `reanim/*.png`: 各独立动画图层的像素内容。
- `properties/resources.xml`: 显式资源 ID 和路径清单；豌豆射手的 13 个 Reanimation 部件不在其中逐项注册。
- `compiled/reanim/*.compiled`: `.reanim` 的预编译二进制定义；覆盖动画结构时需与源 `.reanim` 配套。
- `main.pak`: GOTY 基础 Reanimation、compiled Reanimation、图片及 manifest 的原始容器，本任务只读取。
- `assets/extension`: 高于 dependency 和 base 资源的非破坏性覆盖层；构建后复制到运行目录的 `extension/`。

## Risks / Trade-offs

- 替换共享投射物或阴影会影响其他使用相同资源的内容，必须与植物专用 Reanimation 换皮分开。
- `IMAGE_REANIM_ANIM_SPROUT` 是通用命名资源；若在 extension 中全局覆盖，需先检查其他 Reanimation 是否也引用它。
- 图片尺寸或透明通道变化可能导致锚点、裁剪或边缘异常，本次保持原尺寸与 RGBA 透明。
- 单图片成功只验证图片覆盖通路，不代表已验证 Reanimation 结构替换。
