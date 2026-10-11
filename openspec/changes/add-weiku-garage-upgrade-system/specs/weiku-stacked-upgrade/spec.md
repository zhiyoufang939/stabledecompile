## Purpose

把三个独立威酷选卡项整合为一张 100 阳光的家族卡，并定义受车库永久等级约束的同格 C→B→A 叠种行为及失败时的资源保护规则。

## ADDED Requirements

### Requirement: Single Weiku chooser card
系统 SHALL 在普通选卡界面只提供一张名为“威酷”的家族卡，费用为 100 阳光；WEIKU_B 和 WEIKU_A SHALL 不再作为独立普通选卡项出现。

#### Scenario: View normal seed chooser
- **WHEN** 玩家进入允许威酷使用的普通选卡界面
- **THEN** 界面显示一张 100 阳光的威酷卡，并且不再显示独立的威酷B或威酷A卡

#### Scenario: Select Weiku card
- **WHEN** 玩家选择威酷卡开始关卡
- **THEN** 种子栏只占用一个卡槽，卡片名称、图标、费用与冷却始终代表威酷家族而不是额外生成 B/A 卡槽

### Requirement: First placement creates tier C
系统 SHALL 在空的合法普通植物位置使用威酷卡时创建 WEIKU_C，无论车库已永久解锁到 B、A 或未来更高等级。

#### Scenario: Plant with A unlocked
- **WHEN** 玩家已永久解锁到 A，并在空的合法格子使用威酷卡
- **THEN** 系统消耗 100 阳光、创建 C 级威酷并使该卡进入一次完整冷却

### Requirement: Same-card sequential stacking
系统 SHALL 将威酷卡视为当前威酷实体的下一等级升级卡：同格 C 升为 B，同格 B 升为 A，并通过车辆等级定义解析后续等级。

#### Scenario: Stack C into B
- **WHEN** 玩家已永久解锁 B，并将可用的威酷卡放到同格 C 级威酷上
- **THEN** 系统消耗 100 阳光，以 B 级威酷替换 C，保留格子及合法的底层/外层附属植物，并使卡片进入完整冷却

#### Scenario: Stack B into A
- **WHEN** 玩家已永久解锁 A，并将可用的威酷卡放到同格 B 级威酷上
- **THEN** 系统消耗 100 阳光，以 A 级威酷替换 B，并使卡片进入完整冷却

#### Scenario: Future S stacking
- **WHEN** S 已加入车辆定义且玩家已永久解锁 S
- **THEN** 同一张威酷卡可按定义将同格 A 升为 S，无需新增独立 S 选卡项

### Requirement: Garage unlock gates battle tier
系统 SHALL 禁止战斗内威酷等级超过该玩家在车库中的最高永久解锁等级。

#### Scenario: B is not unlocked
- **WHEN** 玩家仅永久解锁 C，并尝试将威酷卡叠种到 C 上
- **THEN** 系统拒绝操作、提示需要先在车库改装到 B，且不扣阳光、不消耗卡片冷却、不替换场上植物

#### Scenario: A is not unlocked
- **WHEN** 玩家最高永久等级为 B，并尝试将威酷卡叠种到 B 上
- **THEN** 系统拒绝操作并提示需要先解锁 A，且保持阳光、冷却和场上 B 不变

### Requirement: Maximum-tier stacking rejection
系统 SHALL 在目标已经是玩家当前可用的最高定义等级时拒绝继续叠种，并保持所有战斗资源与实体不变。

#### Scenario: Stack onto current maximum
- **WHEN** 玩家已解锁到 A 且把威酷卡放到同格 A 上，而当前定义没有更高等级
- **THEN** 系统提示已达最高等级，不扣除 100 阳光、不消耗冷却且不重置 A 的生命或攻击状态

### Requirement: Invalid target rejection
系统 SHALL 保持现有地形和占位规则；威酷卡只能种在合法空位或可升级的同家族威酷上，不得覆盖其他普通植物或跳级。

#### Scenario: Stack onto unrelated plant
- **WHEN** 玩家把威酷卡放到一个被非威酷普通植物占据的格子
- **THEN** 系统按不可种植处理，不扣阳光、不消耗冷却且不改变目标植物

#### Scenario: Attempt to skip a tier
- **WHEN** 当前目标等级与车辆定义中的下一等级关系不连续
- **THEN** 系统拒绝升级，不创建更高等级实体

### Requirement: Tier-specific combat behavior remains intact
系统 SHALL 让叠种后生成的 C、B、A 实体继续使用各自现有的动画、子弹、攻击节奏和伤害定义。

#### Scenario: Observe upgraded combat
- **WHEN** 场上威酷从 C 升为 B，再从 B 升为 A 并攻击僵尸
- **THEN** 每一级分别使用自己的植物动画与子弹资源，且单发伤害保持 C=20、B=40、A=60

### Requirement: Legacy seed-bank card normalization
系统 SHALL 在恢复旧关卡存档时保留场上现有威酷实体的等级，但 SHALL 将种子栏中旧的独立 WEIKU_B 或 WEIKU_A 卡规范化为单张威酷家族卡，并尽可能保留其当前冷却进度。

#### Scenario: Resume old battle with an A card and A plant
- **WHEN** 玩家恢复一个旧关卡存档，其中种子栏含 WEIKU_A 卡且场上含 WEIKU_A 实体
- **THEN** 场上实体仍为 A，种子栏卡转换为威酷家族卡，后续种植遵循 C 起步和车库等级门槛
