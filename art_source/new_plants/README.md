# 新植物原始贴图投放区

把新植物的原始 PNG 放在：

```text
art_source/new_plants/<plant_id>/
```

这里保存制作输入，不是游戏运行目录。制作时会从这里读取原图，再把整理后的运行资源放入 `assets/extension/`；不要直接修改原版 `main.pak`。

`<plant_id>`、子目录和文件名统一使用 ASCII 英文、数字和下划线。显示给玩家的中文名称与磁盘目录名分离，避免脚本、资源加载器和非宽字符构建处理中文路径。

## 推荐目录与命名

```text
<plant_id>/
├─ reference/                 # 可选：设定图、配色参考
├─ plant/
│  ├─ idle/                   # 必需：整株待机循环
│  │  ├─ idle_000.png
│  │  ├─ idle_001.png
│  │  └─ ...
│  ├─ shoot/                  # 必需：整株攻击动画
│  │  ├─ shoot_000.png
│  │  ├─ shoot_001.png
│  │  ├─ shoot_004_shoot.png  # 用 _shoot 标记子弹离膛帧
│  │  └─ ...
│  └─ card_pose.png           # 可选：卡片/图鉴专用静态姿势
├─ projectile/                # 复用原版豌豆时可省略
│  ├─ projectile.png          # 静态子弹
│  ├─ fly/                    # 可选：动态子弹帧
│  ├─ impact/                 # 可选：自定义命中特效帧
│  └─ trail/                  # 可选：拖尾素材
└─ notes.txt                  # 可选：帧率、发射帧、尺寸和玩法说明
```

## PNG 约定

- 使用带透明通道的 32 位 RGBA PNG；不要带白底、黑底或预乘背景。
- 第一版整株植物建议统一使用 `120 × 120` 像素画布。
- 每一帧必须保持相同画布大小、相同地面接触点和相同中心位置，不要逐帧自动裁边。
- 植物默认朝右；建议地面接触点约为画布 `(60, 105)`，所有帧保持一致。
- `idle_000.png` 应当是适合显示在种子卡和图鉴里的完整、清晰姿势。
- 文件名使用 ASCII 英文、数字和下划线；序号从 `000` 开始并连续。
- 可以上传更高分辨率的绘制源图，但必须同时考虑运行时内存。Reanimation 的缩放参数只改变显示尺寸，不会减少 PNG 解码后的纹理内存。

第一版推荐待机动画 `8–16` 帧、攻击动画 `8–12` 帧。帧数不是硬限制；攻击序列至少应包含准备、后坐/发射和回到待机三个阶段，并用文件名中的 `_shoot` 标记发射时刻。

## 已验证实例：WEIKU

原始素材和可调参数位于：

```text
art_source/new_plants/WEIKU/
```

修改 `timing.ini` 或替换帧后，从仓库根目录运行：

```powershell
& '.\art_source\new_plants\WEIKU\sync_assets.ps1'
```

脚本会：

- 按文件名前导数字读取 `plant/idle/`、`plant/shoot/` 和 `projectile/fly/`；
- 要求攻击序列中恰好有一张 `_shoot.png`；
- 原样复制 PNG 到 `assets/extension/reanim/weiku/`；
- 生成 `assets/extension/reanim/Weiku.reanim`、`WeikuProjectile.reanim`；
- 只更新 `assets/extension/properties/resources.xml` 中带 WEIKU 标记的区块；
- 生成 `Lawn/WeikuConfig.h`，供攻击计时和动画速率使用。

ResourceManifest 必须在 WEIKU 分组内显式设置：

```xml
<SetDefaults path="extension/reanim/weiku" idprefix="" />
```

否则扩展 manifest 会继承此前资源包的默认目录，图片可能被错误解析到 `dependency/sounds/extension/...`。

当前 `DebugGOTY|x64` 为非宽字符构建，游戏内名称暂用 `LawnStrings.txt` 中的 ASCII `WEIKU`。直接将中文宽字符串传给 `WStringToSexyString` 会触发 `Common.cpp` 的字符转换断言；中文显示需要单独解决字体和 Unicode 渲染。

WEIKU 当前 54 张高分辨率运行帧不会预先缩小，加载后内存可超过 1 GB。显示缩放不等于纹理降采样；继续增加植物前应先优化运行贴图尺寸或资源加载方式。
