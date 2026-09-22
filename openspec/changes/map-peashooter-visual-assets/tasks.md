## 1. 确认代码链

- [x] 1.1 确认 `SEED_PEASHOOTER -> gPlantDefs -> REANIM_PEASHOOTER` 及身体/头部实例化代码，以源码路径和符号可重复定位为验证。

## 2. 定位实际 Reanimation

- [x] 2.1 确认 `REANIM_PEASHOOTER -> reanim/PeaShooterSingle.reanim` 注册及 GOTY PAK 内源/compiled 文件，以 PAK 索引内两条真实路径为验证。

## 3. 枚举全部图片依赖

- [x] 3.1 解析 `PeaShooterSingle.reanim` 并枚举所有唯一图片 ID 与轨道，以 13 个实际依赖无遗漏为验证。
- [x] 3.2 核对每张原图的 PAK 路径、尺寸、PNG 存储及透明通道，以 `design.md` 素材表为验证。

## 4. 确认 manifest 与 ID 映射

- [x] 4.1 核对基础 `resources.xml`、`DefinitionLoadImage` 和 `gDefLoadResPaths`，验证 13 个 `IMAGE_REANIM_*` 由动态路径而非显式 manifest 条目解析。
- [x] 4.2 核对共享豌豆投射物和阴影的 manifest ID、源码引用与 PAK 图片，验证它们不属于 `PeaShooterSingle.reanim` 依赖。

## 5. 确认 assets/extension 覆盖机制

- [x] 5.1 核对加载优先级、extension 目录结构与 x64 构建复制规则，以图片覆盖无需修改 PAK、manifest 或 Reanimation 结构为验证。

## 6. 更新 PVZ MOD MAP

- [x] 6.1 创建极简 `PVZ_MOD_MAP.md`，仅写入已确认的代码、Reanimation、贴图与 extension 定位，以文件不含构建/调试日志为验证。

## 7. 最小测试替换

- [x] 7.1 选择 `IMAGE_REANIM_PEASHOOTER_HEAD` 并生成仅改变头部颜色的 70×65 RGBA PNG，以原轮廓、透明背景和尺寸保持为验证。
- [x] 7.2 将唯一测试图放入 `assets/extension/reanim/PeaShooter_Head.png`，以未新增其他视觉覆盖且未修改 `main.pak` 为验证。

## 8. 构建 DebugGOTY x64

- [x] 8.1 使用已验证的临时 `/source-charset:.1252` 和 `DebugGOTY|x64` 命令构建，以 MSBuild 返回 0 为验证。
- [x] 8.2 核对输出目录中 `extension/reanim/PeaShooter_Head.png` 与源覆盖文件哈希一致。

## 9. 启动游戏验证

- [x] 9.1 启动 `build/DebugGOTY_x64/bin/PlantsVsZombies.exe` 并观察初始稳定性，以进程不立即退出且无立即缺失资源崩溃为验证；视觉效果留给用户人工确认。

## 10. 完整换皮素材总结

- [x] 10.1 总结 13 个 Reanimation 素材和 Reanimation 之外的可选共享攻击/阴影素材，以 ID、文件、用途、尺寸、格式、透明和独立部件信息齐全为验证。
