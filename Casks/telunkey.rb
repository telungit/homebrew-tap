cask "telunkey" do
  version "2.1.9"
  sha256 "98a98a88a65d6399e6a5c9fa2de90fdf3f86f0c9a649da8eb66bfe49c8d960c2"

  url "https://github.com/telungit/TelunKey/releases/download/v#{version}/TelunKey.dmg"
  name "TelunKey"
  desc "Global hotkey launcher and window switcher"
  homepage "https://github.com/telungit/TelunKey"

  auto_updates true
  depends_on macos: :sonoma

  app "TelunKey.app"

  preflight_steps do
    run "/usr/bin/pkill",
        args:         ["-x", "TelunKey"],
        must_succeed: false
  end

  # 当前发行包尚未经过 Apple 公证，仅移除隔离标记。
  # 步骤块在 InstallSteps DSL 上下文中求值，路径改用 {{appdir}} 模板令牌展开。
  # 步骤在沙箱内执行，无法连接 LaunchServices，因此不在此处自动启动应用；
  # 升级时由 Homebrew 自身的 "Reopening application(s) closed during upgrade" 负责拉起。
  postflight_steps do
    run "/usr/bin/xattr",
        args: ["-dr", "com.apple.quarantine", "{{appdir}}/TelunKey.app"]
  end

  uninstall quit: "com.telunkey.TelunKey"

  caveats <<~EOS
    On first launch, grant Accessibility permission in System Settings:
      System Settings > Privacy & Security > Accessibility

    Screen Recording permission is optional, required only for real-time window thumbnails:
      System Settings > Privacy & Security > Screen Recording
  EOS
end
