cask "telunkey" do
  version "2.1.0"
  sha256 "51ad156f1d79471ff621266cad76b2acc11916ca2ee3578e37abf701aba11f8c"

  url "https://github.com/telungit/TelunKey/releases/download/v#{version}/TelunKey.dmg"
  name "TelunKey"
  desc "全局快捷键应用启动与窗口切换工具"
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
