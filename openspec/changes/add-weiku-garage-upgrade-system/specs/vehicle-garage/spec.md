## Purpose

提供一个独立、可扩展的车辆车库界面，让玩家浏览已拥有的赛车、查看当前等级属性与成长路径，并从同一界面安全地发起永久改装升级。

## ADDED Requirements

### Requirement: Garage entry and navigation
系统 SHALL 在玩家档案加载后从主界面提供“车库”入口，并允许玩家关闭车库返回原主界面而不开始或中断关卡。

#### Scenario: Open garage from main selector
- **WHEN** 玩家在主界面点击车库入口
- **THEN** 系统打开车库并默认选中第一辆已登记车辆

#### Scenario: Close garage
- **WHEN** 玩家在车库点击返回或关闭
- **THEN** 系统关闭车库并恢复主界面的可操作状态与背景音乐

### Requirement: Garage vehicle presentation
系统 SHALL 按所选车辆当前永久解锁的最高等级，展示中央车辆形象、左上等级与车辆属性、左下基础数值、右侧等级路径、右下改装操作及简短介绍。

#### Scenario: Initial Weiku presentation
- **WHEN** 新档案首次打开车库
- **THEN** 系统仅展示车辆家族“威酷”，并以 C 级形象、C 级属性和简介“威威又酷酷”的可爱语气呈现

#### Scenario: Presentation follows unlocked tier
- **WHEN** 威酷的永久解锁等级从 C 提升到 B 或从 B 提升到 A
- **THEN** 中央形象、等级标识、车辆属性、伤害和其他等级相关展示立即切换到新等级数据

### Requirement: Base stat panel
系统 SHALL 至少展示阳光费用、单发伤害和卡片冷却三个可读数值，并为这些数值提供一致的条形可视化；条形范围 SHALL 来自车辆展示配置而不是硬编码到单辆车辆。

#### Scenario: Display Weiku tier stats
- **WHEN** 玩家查看任一已解锁的威酷等级
- **THEN** 面板显示阳光费用 100、该等级实际单发伤害以及该卡实际冷却，并以配置的范围计算数值条长度

### Requirement: Upgrade path presentation
系统 SHALL 以登记顺序展示车辆从最低等级到最高等级的简略图片，并明确区分已解锁等级、当前最高等级和未解锁等级。

#### Scenario: View C-to-A path
- **WHEN** 威酷最高解锁等级为 B 且当前定义包含 C、B、A
- **THEN** 路径按 C→B→A 排列，C/B 显示为已解锁、B 标记为当前、A 显示为未解锁

#### Scenario: Future tier is added
- **WHEN** 威酷定义在 A 之后新增 S 级
- **THEN** 车库路径按定义顺序追加 S，而无需改变 C/B/A 的显示规则

### Requirement: Upgrade action state
系统 SHALL 根据是否存在下一级、金币是否足够以及升级是否可执行，显示明确的按钮状态、下一等级和费用；任何扣款前 SHALL 要求玩家确认。

#### Scenario: Upgrade is available
- **WHEN** 当前等级存在下一级且玩家显示金币不少于 500,000
- **THEN** “赛车改装”按钮可用，并显示下一等级和 500,000 金币费用

#### Scenario: Insufficient funds
- **WHEN** 当前等级存在下一级但玩家显示金币少于 500,000
- **THEN** 改装按钮不可完成交易，界面显示余额不足，并且不改变等级或金币

#### Scenario: Current maximum reached
- **WHEN** 玩家已经解锁当前定义中的最高等级
- **THEN** 改装按钮显示已达最高等级且不会发起扣款

### Requirement: Safe garage text rendering
系统 SHALL 通过可本地化的字符串资源显示车库标题、属性、按钮和简介，并 SHALL 在当前非宽字符构建不支持中文字形时使用可读的 ASCII 回退文本而不触发字符转换断言。

#### Scenario: Chinese rendering is unavailable
- **WHEN** 当前构建或字体链不能安全显示中文车库文本
- **THEN** 车库使用对应的 ASCII 回退标签和简介，并保持所有交互可用且不崩溃
