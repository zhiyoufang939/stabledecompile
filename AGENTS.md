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

## WEIKU 阶段性成功基线

- 三套独立链路已经接通：`SEED_WEIKU_C/B/A → REANIM_WEIKU_C/B/A → Plant::UpdateShooter/UpdateShooting/Fire → PROJECTILE_WEIKU_C/B/A → REANIM_WEIKU_C/B/A_PROJECTILE`。已完成资源同步、`DebugGOTY|x64` 构建和启动冒烟验证，且用户已在游戏内确认本阶段可用。
- 当前参数：C 为 idle 18 帧、shoot 26 帧（`25_shoot.png`）、fly 10 帧、价格/伤害 101/20；B 为 18、26（`25_shoot.png`）、10、200/40；A 为 18、23（`22_shoot.png`）、10、300/60。三者时长均为 idle 1.0 秒、shoot 1.5 秒、fly 0.8 秒；shoot 周期也是固定攻击间隔。
- C/B 原有 `SeedType` 数值保持不变，A 追加在末尾。选卡界面使用额外最后一行的第一、二、三格，不替换豌豆射手，也不把所有特殊 `SeedType` 加入普通选卡。
- 原始素材目录固定为 ASCII 路径 `art_source/new_plants/WEIKU_C/`、`WEIKU_B/`、`WEIKU_A/`；目录名、文件名和资源 ID 均优先使用 ASCII。各目录的 `notes.txt` 是人工规格说明，脚本不会读取它；实际值仍须落实到 `timing.ini`、素材或 C++ 注册表。
- `timing.ini` 和素材不能由游戏直接读取。修改后必须运行同目录的 `sync_assets.ps1`；脚本按文件名前导数字排序，要求 shoot 序列中恰好一张 `_shoot.png`，并为该变体生成配置头文件、植物/子弹 `.reanim`、ResourceManifest 区块和独立运行贴图目录。不要手工修改这些生成物后期待下次同步保留。
- 同步脚本还会直接更新 `build/DebugGOTY_x64/bin/extension`，并只删除该变体在源码资源目录和运行目录中的 `.reanim.compiled` 缓存。构建复制不会清理目标目录中已经失去来源的旧文件；未被当前 manifest/reanimation 引用的旧通用 WEIKU 文件可以存在，但不应当影响当前链路。
- `plant_display_width` 是标准显示宽度，`plant_scale` 是额外倍率；每帧实际写入 Reanimation 的缩放为 `plant_display_width * plant_scale / 原始 PNG 宽度`。因此它不是固定的 `0.11111`，也不表示 120×80 画布。idle 与 shoot 原图宽度不同会得到不同的内部 `sx/sy`，但标准化后的显示宽度一致。植物只使用一套 `plant_scale`，shoot 自动按自己的原图尺寸换算。
- `plant_anchor_x/y` 调整整株植物在格子中的视觉位置；`projectile_scale` 与 `projectile_anchor_x/y` 独立控制子弹的显示尺寸和视觉偏移。`muzzle_x/y` 是以植物格子左上角为参照的真实子弹生成/碰撞起点，不是贴图锚点。
- `assets/extension/properties/resources.xml` 中三个区块必须分别显式使用 `extension/reanim/weiku_c`、`weiku_b`、`weiku_a` 的 `<SetDefaults ... />`；否则会继承前一 manifest 的 `dependency/sounds/` 默认路径。
- 配置头文件中的帧数、时间、发射帧和枪口坐标被 C++ 使用；这些项目变化后必须重新构建。为避免漏判，日常采用固定流程：修改 → 运行对应同步脚本 → 构建 → 从正确运行目录启动 → 游戏内人工确认。
- 直接运行 `build/DebugGOTY_x64/bin/PlantsVsZombies.exe` 时工作目录应为同一个 `bin`，且其中必须有构建复制的依赖资源；桌面快捷方式还必须核对目标 EXE 和“起始位置”。缺少 `dependency.pak` 是运行目录/资源副本问题，不是 `timing.ini` 缓存问题。
- 本构建是非宽字符版本。不要在卡片名称/提示中直接调用 `WStringToSexyString` 转换中文，否则会在 `Common.cpp` 的 `wcstombs` 断言。当前使用 `LawnStrings.txt` 中的 ASCII 名称 `WEIKU_C`、`WEIKU_B`、`WEIKU_A`；中文显示需另接 Unicode 字体与渲染链。
- 仅检查进程存活不足以证明启动成功：Fatal Error / assertion 对话框出现时进程可能仍存在。必须进入选卡界面，分别选择、放置并观察 idle、shoot、发射帧、fly 和命中。
- 高分辨率 PNG 会原样复制，Reanimation 缩放只改变显示尺寸，不降低纹理解码内存。B/C 各 54 帧，A 51 帧；单套实测即可令进程内存超过 1 GB。继续增加植物前应优先做运行贴图降采样、分组加载或纹理压缩。
