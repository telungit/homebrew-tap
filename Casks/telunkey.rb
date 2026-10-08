cask "telunkey" do
  version "2.0.5"
  sha256 "b33f9a7631f240d68f1b7ce740cdece1fc01e14754bbb76fb94d39e2b213395a"

  url "https://github.com/telungit/TelunKey/releases/download/v#{version}/TelunKey.dmg"
  name "TelunKey"
  desc "全局快捷键应用启动与窗口切换工具"
  homepage "https://github.com/telungit/TelunKey"

  auto_updates true
  depends_on macos: :sonoma

  preflight_steps do
    run "/usr/bin/pkill",
        args:         ["-x", "TelunKey"],
        must_succeed: false
  end

  app "TelunKey.app"
  uninstall quit: "com.telunkey.TelunKey"

  # 当前发行包尚未经过 Apple 公证，仅移除隔离标记并自动启动应用。
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-dr", "com.apple.quarantine", "#{appdir}/TelunKey.app"]
    system_command "/usr/bin/open",
                   args: ["-a", "#{appdir}/TelunKey.app"]
  end

  caveats <<~EOS
    On first launch, grant Accessibility permission in System Settings:
      System Settings > Privacy & Security > Accessibility

    Screen Recording permission is optional, required only for real-time window thumbnails:
      System Settings > Privacy & Security > Screen Recording
  EOS
end
