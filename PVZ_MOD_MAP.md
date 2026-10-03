# PVZ MOD MAP

| 内容 | 文件 / 目录 | 参数 / 资源 |
|---|---|---|
| 豌豆射手价格 | `Lawn/Plant.cpp` | `gPlantDefs -> SEED_PEASHOOTER -> mSeedCost` |
| 豌豆射手动画入口 | `Lawn/Plant.cpp` | `gPlantDefs -> SEED_PEASHOOTER -> REANIM_PEASHOOTER` |
| 豌豆射手 Reanimation 注册 | `Sexy.TodLib/Reanimator.cpp` | `gLawnReanimationArray -> reanim/PeaShooterSingle.reanim` |
| 豌豆射手 Reanimation 原始资源 | `Plants Vs Zombies/main.pak` | `reanim/PeaShooterSingle.reanim`; `compiled/reanim/PeaShooterSingle.reanim.compiled` |
| 豌豆射手贴图 | `Plants Vs Zombies/main.pak` | `PeaShooterSingle.reanim` 引用的 13 个 `IMAGE_REANIM_*` / `reanim/*.png` |
| Reanimation 图片解析 | `Sexy.TodLib/Definition.cpp` | `DefinitionLoadImage -> gDefLoadResPaths` |
| 扩展资源覆盖 | `assets/extension/reanim/` | 同路径同名图片优先于基础 `main.pak` 资源 |
| 豌豆射手头部测试覆盖 | `assets/extension/reanim/PeaShooter_Head.png` | `IMAGE_REANIM_PEASHOOTER_HEAD -> anim_face` |

## 豌豆射手攻击链路

| 内容 | 文件 | 函数 / 参数 |
|---|---|---|
| 攻击更新入口 | `Lawn/Plant.cpp` | `Plant::Update -> UpdateShooter` |
| 目标判断 | `Lawn/Plant.cpp` | `UpdateShooter -> FindTargetAndFire -> FindTargetZombie`; `GetPlantAttackRect` |
| 发射动画 | `Lawn/Plant.cpp` | `FindTargetAndFire`; 头部 `anim_shooting`; `REANIM_PLAY_ONCE_AND_HOLD`; `mAnimRate = 35.0f` |
| 发射同步 | `Lawn/Plant.cpp` | `mShootingCounter = 33`; `UpdateShooting` 递减至 `1` 时调用 `Fire` |
| 子弹创建 | `Lawn/Plant.cpp`; `Lawn/Board.cpp` | `Plant::Fire -> Board::AddProjectile -> Projectile::ProjectileInitialize` |
| 豌豆子弹类型 | `ConstEnums.h`; `Lawn/Plant.cpp` | `ProjectileType::PROJECTILE_PEA`; `Plant::Fire` |
| 豌豆伤害 | `Lawn/Projectile.cpp` | `gProjectileDefinition[PROJECTILE_PEA].mDamage = 20`; `Projectile::DoImpact` |
| 豌豆速度 | `Lawn/Projectile.cpp` | `Projectile::UpdateNormalMotion`; 直线运动每次更新 `mPosX += 3.33f` |
| 发射位置 | `Lawn/Plant.cpp` | `GetPeaHeadOffset`; `aOriginX = mX + aOffsetX + 24`; `aOriginY = mY + aOffsetY - 33` |
| 攻击间隔 | `Lawn/Plant.cpp`; `Lawn/Plant.h` | `gPlantDefs -> SEED_PEASHOOTER -> mLaunchRate = 150`; `UpdateShooter -> mLaunchRate - Rand(15)` |
| 子弹贴图 | `Lawn/Projectile.cpp`; `Plants Vs Zombies/main.pak` | `Projectile::Draw -> IMAGE_PROJECTILEPEA -> properties/resources.xml -> images/ProjectilePea.png` |
| 子弹动画 | `Lawn/Projectile.cpp` | 普通豌豆无 Reanimation；`mNumFrames = 1`; `mAnimTicksPerFrame = 0`; `mFrame = 0` |
| 子弹更新 / 命中 | `Lawn/Board.cpp`; `Lawn/Projectile.cpp` | `Board::UpdateGameObjects -> Projectile::Update -> UpdateMotion -> UpdateNormalMotion -> CheckForCollision -> DoImpact` |
| 命中特效 | `Lawn/Projectile.cpp` | `Projectile::DoImpact -> PARTICLE_PEA_SPLAT` |

`Plant::Update -> UpdateShooter -> FindTargetAndFire -> anim_shooting + mShootingCounter -> UpdateShooting -> Fire -> Board::AddProjectile -> Projectile::Update/UpdateNormalMotion -> Projectile::Draw/DoImpact`

## 新增全新植物

| 内容 | 文件 | 枚举 / 函数 / 参数 |
|---|---|---|
| SeedType 定义 | `ConstEnums.h` | `SeedType`; `NUM_SEED_TYPES`; `NUM_SEEDS_IN_CHOOSER` |
| PlantDefinition 注册 | `Lawn/Plant.h`; `Lawn/Plant.cpp` | `PlantDefinition`; `gPlantDefs`; `GetPlantDefinition` |
| Reanimation 注册 | `ConstEnums.h`; `Sexy.TodLib/Reanimator.cpp` | `ReanimationType`; `NUM_REANIMS`; `gLawnReanimationArray` |
| 植物创建 / 生命周期 | `Lawn/Board.cpp`; `Lawn/Plant.cpp` | `Board::NewPlant`; `Board::AddPlant`; `PlantInitialize`; `Update`; `Draw` |
| 植物行为入口 | `Lawn/Plant.cpp` | `Plant::Update`; `PlantInitialize`; `DoSpecial`; SeedType 分派与分类函数 |
| 攻击逻辑 | `Lawn/Plant.cpp` | `SUBCLASS_SHOOTER`; `UpdateShooter`; `FindTargetAndFire`; `Fire` |
| 卡片 / Seed Packet | `Lawn/SeedPacket.cpp`; `Lawn/System/ReanimationLawn.cpp` | `DrawSeedPacket`; `SeedPacket::SetPacketType`; `Plant::DrawSeedType`; `mPlantImages[NUM_SEED_TYPES]` |
| 选卡界面 / 解锁 | `Lawn/Widget/SeedChooserScreen.cpp`; `LawnApp.cpp` | `mChosenSeeds[NUM_SEED_TYPES]`; `NUM_SEEDS_IN_CHOOSER`; `HasSeedType`; `SeedTypeAvailable` |
| 图鉴 | `Lawn/Widget/AlmanacDialog.h`; `Lawn/Widget/AlmanacDialog.cpp` | `NUM_ALMANAC_SEEDS`; `DrawPlants`; `GetSeedPosition` |
| 名称 / 提示 / 描述 | `Lawn/Plant.cpp`; `assets/extension/properties/LawnStrings.txt` | `mPlantName`; `[ID]`; `[ID_TOOLTIP]`; `[ID_DESCRIPTION]` |
| Projectile | `ConstEnums.h`; `Lawn/Projectile.h`; `Lawn/Projectile.cpp`; `Lawn/Plant.cpp` | `ProjectileType`; `gProjectileDefinition`; `ProjectileInitialize`; `UpdateMotion`; `Draw`; `Plant::Fire` |
| Reanimation / 图片资源 | `assets/extension/reanim/`; `assets/extension/compiled/reanim/` | `.reanim`; `.reanim.compiled`; Reanimation 引用的 PNG |
| ResourceManifest | `assets/extension/properties/resources.xml`; `Resources.h`; `Resources.cpp` | 独立图片 / 声音资源 ID；源码全局资源变量及加载表 |
| NUM_SEED_TYPES 相关数组 | `Lawn/Plant.cpp`; `Lawn/SeedPacket.cpp`; `Lawn/System/ReanimationLawn.h`; `Lawn/Widget/SeedChooserScreen.h` | `gPlantDefs`; 权重数组；`mPlantImages`; `mChosenSeeds` |
| 存档 / 枚举兼容 | `Lawn/System/PlayerInfo.h`; `Lawn/System/PlayerInfo.cpp`; `Lawn/System/SaveGame.cpp` | `mPlantedPlants[SEED_LEFTPEATER]`; `SyncDetails`; `SyncBoard`；保留已有 SeedType 数值 |
| 解锁 / 关卡植物列表 | `LawnApp.cpp`; `Lawn/Board.cpp`; `Lawn/CutScene.cpp`; `Lawn/Challenge.cpp` | `GetAwardSeedForLevel`; `GetSeedsAvailable`; `HasSeedType`; 各模式固定植物列表 |

SeedType
→ NUM_SEED_TYPES / 固定边界审计
→ gPlantDefs
→ ReanimationType / 资源
→ PlantInitialize
→ Update / 特殊行为
→ Fire / Projectile（攻击植物）
→ Draw / SeedPacket
→ SeedChooser / 解锁
→ Almanac / LawnStrings
→ SaveGame / PlayerInfo 兼容检查

| 新植物基础表项 | `Lawn/Plant.cpp` | `gPlantDefs[new SeedType]`；索引必须与 `SeedType` 数值严格一致 |
| 新植物行为初始化 | `Lawn/Plant.cpp` | `Plant::PlantInitialize`；特殊植物按 `SeedType` 增加初始化 |
| 新植物特殊 Update | `Lawn/Plant.cpp` | `Plant::Update` / `DoSpecial`；普通植物可复用默认流程 |
| 新射手 Fire 分派 | `Lawn/Plant.cpp` | `Plant::Fire`；新的攻击型 `SeedType` 通常必须增加 Projectile 映射 |
| 枪口 / 攻击范围 | `Lawn/Plant.cpp` | `GetPlantAttackRect`; 发射坐标相关函数 |
| 正常选卡数量边界 | `ConstEnums.h`; `SeedChooserScreen.cpp` | `NUM_SEEDS_IN_CHOOSER`；不能直接等于 `NUM_SEED_TYPES` |
| 模仿者植物范围 | `Lawn/Widget/ImitaterDialog.cpp` | 固定 SeedType 范围；新植物不会自动加入 |
| 图鉴植物数量 | `AlmanacDialog.h/.cpp` | `NUM_ALMANAC_SEEDS`；高编号植物不会自动正确布局 |
| Adventure 解锁 | `LawnApp.cpp` | `GetAwardSeedForLevel`; `GetSeedsAvailable`; `HasSeedType` |
| 存档固定植物数组 | `PlayerInfo.h/.cpp` | `mPlantedPlants[...]`；修改范围可能影响存档格式 |
| SeedType 存档兼容 | `ConstEnums.h`; `SaveGame.cpp` | 旧枚举值不可重新排序；新增类型应避免插入旧枚举之间 |

## WEIKU 实现定位

| 内容 | 文件 / 目录 | 参数 / 链路 |
|---|---|---|
| 原始素材与时间配置 | `art_source/new_plants/WEIKU/` | `timing.ini`; `sync_assets.ps1`; `plant/idle`; `plant/shoot`; `projectile/fly` |
| 生成的编译期配置 | `Lawn/WeikuConfig.h` | 帧数、idle/shoot/fly 时长、`kFireFrameIndex`、`kShootTicks`、`kFireCounter` |
| 植物注册 | `ConstEnums.h`; `Lawn/Plant.cpp` | `SEED_WEIKU`; `gPlantDefs`; `REANIM_WEIKU`; `SUBCLASS_SHOOTER` |
| 攻击计时与发射 | `Lawn/Plant.cpp` | `FindTargetAndFire`; `UpdateShooter`; `UpdateShooting`; `Plant::Fire`; `_shoot.png` 对应 `kFireCounter` |
| 子弹注册与绘制 | `ConstEnums.h`; `Lawn/Projectile.cpp` | `PROJECTILE_WEIKU`; `REANIM_WEIKU_PROJECTILE`; 20 伤害；直线速度复用普通射弹更新 |
| Reanimation 注册 | `ConstEnums.h`; `Sexy.TodLib/Reanimator.cpp` | `REANIM_WEIKU`; `REANIM_WEIKU_PROJECTILE`; `Weiku.reanim`; `WeikuProjectile.reanim` |
| 运行贴图 | `assets/extension/reanim/weiku/` | `idle_*.png`; `shoot_*.png`; `fly_*.png` |
| 资源清单 | `assets/extension/properties/resources.xml` | WEIKU 生成区块；`SetDefaults path="extension/reanim/weiku" idprefix=""` |
| compiled 缓存 | `assets/extension/compiled/reanim/` | `Weiku.reanim.compiled`; `WeikuProjectile.reanim.compiled`；XML 较新时运行时重编译 |
| 名称与提示 | `assets/extension/properties/LawnStrings.txt` | `[WEIKU]`; `[WEIKU_TOOLTIP]`; 当前使用 ASCII 避免非宽字符转换断言 |
| 独立选卡入口 | `Lawn/Widget/SeedChooserScreen.cpp`; `LawnApp.cpp` | `SeedTypeIsInNormalChooser`; 最后一行第一格；`HasSeedType(SEED_WEIKU)` |

## 玩家金币

| 内容 | 文件 | 参数 / 说明 |
|---|---|---|
| 玩家金币设为 10000000 | `Lawn/System/PlayerInfo.cpp` | `PlayerInfo::SyncDetails` 在读取存档后将 `mCoins` 设为 `1000000`；`PlayerInfo::Reset` 同步设置新档案初始值。`LawnApp::GetMoneyString` 按内部值的 10 倍显示，因此游戏内显示为 `10000000` |
