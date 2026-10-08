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
    run "/usr/bin/osascript",
        args:         ["-e", 'if application id "com.telunkey.TelunKey" is running then tell application id "com.telunkey.TelunKey" to quit'],
        must_succeed: false
    run "/bin/sh",
        args:         ["-c", 'killall TelunKey 2>/dev/null || true'],
        must_succeed: false
  end

  app "TelunKey.app"
  uninstall quit: "com.telunkey.TelunKey"

  # 当前发行包尚未经过 Apple 公证，仅移除本次安装应用的隔离标记。
  postflight_steps do
    run "/usr/bin/xattr",
        args:           ["-dr", "com.apple.quarantine", "{{appdir}}/TelunKey.app"],
        writable_paths: ["TelunKey.app"],
        writable_base:  :appdir
  end

  caveats <<~EOS
    首次运行需在“系统设置”中授予“辅助功能”权限；
    如需窗口实时缩略图，另需授予“屏幕录制”权限（可选）。
  EOS
end
