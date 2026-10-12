cask "telunkey" do
  version "2.1.2"
  sha256 "89246652bdd81d1ff9f0536b45e079670c6d8cfad4e32c1789a6cd34b622cd3a"

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

  # 当前发行包尚未经过 Apple 公证，仅移除隔离标记并自动启动应用。
  # 步骤块在 InstallSteps DSL 上下文中求值，路径改用 {{appdir}} 模板令牌展开。
  postflight_steps do
    run "/usr/bin/xattr",
        args: ["-dr", "com.apple.quarantine", "{{appdir}}/TelunKey.app"]
    run "/usr/bin/open",
        args: ["-a", "{{appdir}}/TelunKey.app"]
  end

  uninstall quit: "com.telunkey.TelunKey"

  caveats <<~EOS
    On first launch, grant Accessibility permission in System Settings:
      System Settings > Privacy & Security > Accessibility

    Screen Recording permission is optional, required only for real-time window thumbnails:
      System Settings > Privacy & Security > Screen Recording
  EOS
end
