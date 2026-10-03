# StableDecompile 项目约定

## 路径与安全边界

- 仓库：`D:\PVZ_Mod\stabledecompile`
- Steam 原版：`D:\steam\steamapps\common\Plants Vs Zombies`，只读；禁止修改其 `main.pak`、EXE 或其他文件。
- 仓库内 `Plants Vs Zombies/` 是运行资源副本，已加入 `.git/info/exclude`，不要提交正版资源。
- 保留所有既有未提交修改；未经明确要求，不执行 reset/restore/clean、commit 或 push。
- 详细代码/资源定位以 `PVZ_MOD_MAP.md` 为准；该文件只记定位，不写日志。

## 已验证基线

- `DebugGOTY | x64` 已成功编译并进入主菜单。
- 输出：`build/DebugGOTY_x64/bin/PlantsVsZombies.exe`
- Visual Studio 实际工具链：MSBuild `D:\Visual studio\MSBuild\Current\Bin\MSBuild.exe`、`v145`、`14.44.35207`。
- 工程声明 `v143`，本机使用命令行覆盖为 `v145`；不要修改 `.vcxproj`/`.user` 的工具集，也不要安装或切换工具集，除非用户明确要求。
- 源码含 Windows-1252 文件；构建时临时设置 `CL=/source-charset:.1252`，不要写入系统环境变量，也不要顺手转换编码或处理普通 warning。

## 已验证构建与启动

```powershell
$env:CL = '/source-charset:.1252'

& 'D:\Visual studio\MSBuild\Current\Bin\MSBuild.exe' `
  'D:\PVZ_Mod\stabledecompile\PlantsVsZombies.sln' `
  /t:Build `
  /p:Configuration=DebugGOTY `
  /p:Platform=x64 `
  /p:PlatformToolset=v145 `
  /p:VCToolsVersion=14.44.35207 `
  /m /v:minimal /nologo

& 'D:\PVZ_Mod\stabledecompile\build\DebugGOTY_x64\bin\PlantsVsZombies.exe'
```

每次源码或资源修改后按“修改 → 构建 → 启动 → 游戏内人工确认”验证；DirectX 窗口无法截图不等于启动失败。

## 已确认修改与链路

- 豌豆射手价格：`Lawn/Plant.cpp` → `gPlantDefs[SEED_PEASHOOTER].mSeedCost`，已由 `100` 改为 `101` 并完成构建/启动链路验证。
- 豌豆射手视觉覆盖：`SEED_PEASHOOTER → gPlantDefs → REANIM_PEASHOOTER → reanim/PeaShooterSingle.reanim → IMAGE_REANIM_*`；测试覆盖为 `assets/extension/reanim/PeaShooter_Head.png`，不要改原始 `main.pak`。
- 资源优先级：`resourcepack → extension → dependency → main.pak`。MOD 资源优先放 `assets/extension/`；新 Reanimation 的 x64 运行需要 `.reanim`、`compiled/reanim/*.compiled` 和引用的 PNG。
- 豌豆射手攻击链：`Plant::Update → UpdateShooter → FindTargetAndFire → anim_shooting/mShootingCounter → Fire → Board::AddProjectile → Projectile::Update/Draw/DoImpact`。
- 玩家金币：`Lawn/System/PlayerInfo.cpp` 在读档后及 `Reset()` 中设置内部值 `mCoins = 1000000`；界面按 10 倍显示为 `10000000`。

## 新增植物前的关键约束

- `SeedType` 是 `gPlantDefs` 和多个固定数组的直接下标；不要重排旧枚举值。
- `NUM_SEEDS_IN_CHOOSER` 不等于 `NUM_SEED_TYPES`，不能简单扩大后让所有特殊 SeedType 进入普通选卡界面。
- 新攻击植物通常还要接入 `Plant::Fire`；自定义子弹才新增 `ProjectileType`。
- 存档直接保存部分 `SeedType`/对象内存；修改枚举或固定数组前必须先设计兼容方案。
