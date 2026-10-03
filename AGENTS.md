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

## WEIKU 已验证技术路线

- 原始素材目录固定为 ASCII 路径 `art_source/new_plants/WEIKU/`；新植物的目录名、文件名和资源 ID 都优先使用 ASCII，避免 PowerShell、资源加载器和非宽字符构建中的中文路径问题。
- 修改 `art_source/new_plants/WEIKU/timing.ini` 后运行 `& '.\art_source\new_plants\WEIKU\sync_assets.ps1'`。脚本按文件名前导数字排序，要求恰好一张攻击帧以 `_shoot.png` 结尾，并生成 `Lawn/WeikuConfig.h`、两个 `.reanim`、ResourceManifest 区块以及 `assets/extension/reanim/weiku/` 运行贴图。
- 当前动画配置：idle 18 帧 / 1.0 秒，shoot 26 帧 / 1.5 秒，fly 10 帧 / 0.8 秒；`25_shoot.png` 决定生成子弹的时刻。shoot 周期同时作为 WEIKU 的固定攻击间隔。
- 独立植物链路为 `SEED_WEIKU → REANIM_WEIKU → Plant::UpdateShooter/UpdateShooting/Fire → PROJECTILE_WEIKU → REANIM_WEIKU_PROJECTILE`。选卡界面使用额外最后一行，不替换豌豆射手，也不把特殊 SeedType 全部加入普通选卡。
- `assets/extension/properties/resources.xml` 中 WEIKU 区块必须显式使用 `<SetDefaults path="extension/reanim/weiku" idprefix="" />`；否则会继承前一个 manifest 的 `dependency/sounds/` 默认路径。
- 本构建是非宽字符版本。不要在卡片名称/提示中直接调用 `WStringToSexyString` 转换中文；会在 `Common.cpp` 的 `wcstombs` 断言。当前通过 `assets/extension/properties/LawnStrings.txt` 使用 ASCII 名称 `WEIKU`；真正显示中文需要另行接入含中文字形的 Unicode 字体链。
- `.reanim.compiled` 是否有效由 XML 与 compiled 文件的修改时间判断。变更帧序列后必须重新运行同步脚本、构建并启动，让运行时重新生成缓存；发布时保留匹配的 `assets/extension/compiled/reanim/*.compiled`。
- 仅检查进程存活不足以证明启动成功：Fatal Error / assertion 对话框出现时进程可能仍存在。必须人工进入选卡界面、选择 WEIKU、放置并观察 idle、shoot、发射帧、fly 和命中。
- 当前高分辨率 PNG 会原样复制，只在 Reanimation 中缩放；画质得以保留，但实测加载全部 54 帧后进程内存可超过 1 GB。后续增加植物前应优先设计运行贴图降采样、分组加载或纹理压缩方案。
