# TelunKey Homebrew Tap

TelunKey 官方维护的独立 Homebrew tap，安装包来自 [TelunKey 的公开 Release](https://github.com/telungit/TelunKey/releases)。支持 macOS 14.0 及以上、Intel 和 Apple Silicon。

## 安装

先安装 [Homebrew](https://brew.sh/)，然后执行：

```bash
brew update
brew install --cask telungit/tap/telunkey
```

安装完成后，从“应用程序”打开 TelunKey。首次运行仍需在系统设置中授予辅助功能权限；屏幕录制权限用于窗口缩略图，不授权时显示应用图标。

当前发行包尚未经过 Apple 公证。配方会在安装完成后对本次安装的 `TelunKey.app` 自动执行 `xattr -dr com.apple.quarantine`，无需用户单独运行修复命令。此操作仅针对该应用，不关闭系统 Gatekeeper，且支持自定义 `--appdir`。

使用最新 Homebrew。配方采用结构化 `postflight_steps`；如果出现不认识该字段的错误，先运行 `brew update`。完整名称安装会自动信任这一条配方，无需额外运行 `brew trust`；信任配方与 Apple 公证是不同机制。参见 [Homebrew Tap Trust](https://docs.brew.sh/Tap-Trust) 与 [Cask 安装步骤](https://docs.brew.sh/Cask-Cookbook#stanza-flight_steps)。

## 从手动安装迁移

先退出 TelunKey。若“应用程序”已有手动安装的 `TelunKey.app`，先将它移到其他文件夹备份，再执行普通安装命令。Homebrew 默认会拒绝覆盖已有应用；移动应用不会清空用户配置。

如果只想让 Homebrew 接管现有应用、保留当前应用内容，也可以使用：

```bash
brew install --cask --adopt telungit/tap/telunkey
```

`--adopt` 不是更新命令。由于配方声明了 `auto_updates true`，Homebrew 接管时可能保留不同版本的现有应用，并按配方版本登记安装记录；接管成功不代表应用已升级。实际版本以 TelunKey 的“关于”窗口为准。要确保安装配方指定的版本，使用上面的备份后普通安装流程。

## 更新与卸载

应用内的更新功能仍然可用。若要通过 Homebrew 更新，先退出 TelunKey，再执行：

```bash
brew update
brew upgrade --cask --greedy telungit/tap/telunkey
```

配方声明了 `auto_updates true`；这里显式使用 `--greedy`，确保 Homebrew 按 tap 配方执行更新。应用内更新与 tap 配方分别维护，如果应用内已经更新到比 tap 更高的版本，应等待配方同步后再通过 Homebrew 更新，避免被替换为 tap 中的旧版本。

重新安装或卸载：

```bash
brew reinstall --cask telungit/tap/telunkey
brew uninstall --cask telungit/tap/telunkey
```

卸载保留用户配置。

## 维护发行版本

1. 按既有流程将正式 DMG 与 `.sha256` 发布到 `telungit/TelunKey` 的公开 Release，不向 tap 或源码仓库提交 DMG。
2. 在 Homebrew 已克隆的 tap 目录运行更新脚本。默认读取最新正式 Release，也可以显式指定版本：

```bash
cd "$(brew --repository telungit/tap)"
git pull --ff-only
python3 Tools/update_cask.py
```

也可以将最后一条命令替换为 `python3 Tools/update_cask.py --tag v<目标版本号>`，只运行其中一种同步方式。

脚本实际下载 DMG，计算 SHA-256，并与 GitHub 资产摘要及发布的校验文件交叉校验；所有检查通过后才修改配方的版本和摘要。脚本拒绝回退版本或替换同一版本的 DMG 摘要。Release 必须使用 `v<版本号>` 标签并包含 `TelunKey.dmg` 与 `TelunKey.dmg.sha256`。

3. 检查 DMG 中应用版本、最低系统版本和 CPU 架构与配方声明一致。审查配方差异并验证：

```bash
ruby -c Casks/telunkey.rb
brew style --cask telungit/tap/telunkey
git diff --check
git diff -- Casks/telunkey.rb
```

4. 提交并推送配方，用户下一次 `brew update` 后即可获取新版本：

```bash
git add Casks/telunkey.rb
git commit -m "更新 TelunKey Homebrew 发行版本"
git push origin main
```

每个 Release 标签下的 DMG 应保持不变；重新打包时发布新版本，避免已发布配方出现校验失败。未来完成 Developer ID 签名与 Apple 公证后，可删除自动移除隔离标记的安装步骤及对应说明。
