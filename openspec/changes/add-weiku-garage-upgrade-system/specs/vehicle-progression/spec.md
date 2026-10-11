## Purpose

定义与具体 UI 和植物分支解耦的车辆家族、等级顺序、永久解锁和金币改装规则，使威酷及未来车辆或 S 级能够通过数据扩展并可靠保存。

## ADDED Requirements

### Requirement: Data-driven vehicle tier definitions
系统 SHALL 为每个车辆家族提供稳定车辆 ID，并以有序等级定义关联等级 ID、战斗形态、展示数据、升级费用和前后级关系；车库和战斗系统 SHALL 使用该定义查询等级而不是假定只有 C/B/A。

#### Scenario: Resolve Weiku tiers
- **WHEN** 系统加载首期威酷定义
- **THEN** 系统将 C、B、A 解析为同一车辆家族中连续的三个等级，并能从任一级查询前一级和后一级

#### Scenario: Add or remove a future tier
- **WHEN** 开发者在车辆定义中增加 S 或移除尚未发布的等级
- **THEN** 等级路径、下一等级查询和最高等级判断按新定义工作，无需为该字母等级增加专用判断

### Requirement: Initial persistent unlock
系统 SHALL 为每个已登记车辆家族保存最高永久解锁等级；新档案中的威酷 SHALL 默认解锁 C，且不得默认解锁 B 或 A。

#### Scenario: Create a new profile
- **WHEN** 玩家创建或重置档案
- **THEN** 威酷最高永久解锁等级为 C

### Requirement: Sequential coin upgrade transaction
系统 SHALL 只允许从当前最高永久等级升级到定义中的紧邻下一级；威酷 C→B 和 B→A 每步 SHALL 分别消耗界面显示的 500,000 金币，并作为一次原子交易完成。

#### Scenario: Upgrade C to B
- **WHEN** 威酷最高等级为 C、玩家确认改装且显示金币不少于 500,000
- **THEN** 系统扣除恰好 500,000 显示金币，将最高等级设为 B，并立即保存档案

#### Scenario: Upgrade B to A
- **WHEN** 威酷最高等级为 B、玩家确认改装且显示金币不少于 500,000
- **THEN** 系统再次扣除恰好 500,000 显示金币，将最高等级设为 A，并立即保存档案

#### Scenario: Transaction precondition changes
- **WHEN** 确认交易时余额不足、当前等级已变化或已不存在下一级
- **THEN** 系统同时保持金币和最高解锁等级不变，并向玩家报告交易未完成

### Requirement: Coin balance persistence
系统 SHALL 保存改装后的真实金币余额；加载已有档案时不得用测试初始值覆盖已保存余额，新建或重置档案仍可使用项目配置的初始金币。

#### Scenario: Reload after an upgrade
- **WHEN** 玩家完成一次 500,000 金币改装、退出并重新加载同一档案
- **THEN** 重新加载后的余额保持扣款后的数值，已解锁等级也保持不变

### Requirement: Profile migration compatibility
系统 SHALL 使用可识别的档案版本迁移旧玩家数据；旧版本没有车辆字段时 SHALL 将威酷初始化为 C，同时保留可成功读取的金币、进度、购买和其他既有字段。

#### Scenario: Load a pre-garage profile
- **WHEN** 系统读取一个车库功能加入前的有效玩家档案
- **THEN** 档案成功迁移，威酷最高等级为 C，原有玩家数据不因缺少车辆字段而被整体重置

#### Scenario: Save and reload migrated profile
- **WHEN** 迁移后的档案被保存并再次加载
- **THEN** 系统按新版本格式读取相同的车辆等级和其他玩家数据

### Requirement: Existing battle-save compatibility
系统 SHALL 保留现有 WEIKU_C、WEIKU_B、WEIKU_A 的稳定枚举值和运行定义，使包含任一级威酷实体的旧关卡存档仍能恢复该实体原等级。

#### Scenario: Load old board containing Weiku A
- **WHEN** 玩家加载一个功能变更前保存且场上包含 WEIKU_A 的有效关卡存档
- **THEN** 该实体仍以 A 级资源、攻击逻辑和伤害恢复，不被降级为 C 或丢失
