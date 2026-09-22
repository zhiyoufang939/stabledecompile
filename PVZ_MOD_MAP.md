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
