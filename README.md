# ShaChiProbe — 影之刃零攻击回煞 Mod

一款基于 **UE4SS** 的 Lua Mod，用于在玩家攻击时，根据造成的 **Poise 伤害（架势伤害）** 和 **物理伤害** 恢复煞气。

## 功能介绍

- 根据攻击的物理伤害与 Poise 伤害计算煞气恢复量。
- 将恢复后的煞气限制在角色当前的煞气上限内。
- 当前使用统一的恢复公式，尚未根据武器类型区分恢复机制。

当前代码中的计算公式为：

```text
煞气恢复量 =（物理伤害 + Poise 伤害）× 0.01
```

如需调整统一恢复倍率，可修改 `scripts/main.lua` 中 `CalculateShaChiRecovery` 函数里的 `0.01`。

## 使用前提

- 游戏：《影之刃零》
- 已安装与游戏版本兼容、能够正常运行的 UE4SS，并包含其 `UEHelpers` 模块。

## 安装方法

1. 下载或克隆本仓库。
2. 将包含 `scripts` 目录的项目文件夹命名为 `ShaChiProbe`，放入 UE4SS 的 `Mods` 目录。若使用 GitHub 的 ZIP 下载，请将解压后的文件夹重命名为 `ShaChiProbe`。
3. 确认目录结构如下：

   ```text
   Mods/
   ├── mods.txt
   └── ShaChiProbe/
       └── scripts/
           └── main.lua
   ```

4. 在现有的 `Mods/mods.txt` 中添加以下一行并保存：

   ```text
   ShaChiProbe : 1
   ```

5. 启动游戏。可在 UE4SS 日志中查看 `[ShaChi] Mod Load!` 加载信息及 `[ShaChiProbe]` 伤害、回煞日志。

## TODO

- [ ] 根据不同武器，实现定制化的煞气恢复机制。

## 许可证

本项目采用 [MIT 许可证](LICENSE)。
