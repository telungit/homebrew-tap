cask "telunkey" do
  version "2.0.4"
  sha256 "89dbb23e8c47ea474c6a1bc3865f481cb75dc9120e13fe00006956862a969889"

  url "https://github.com/telungit/TelunKey/releases/download/v#{version}/TelunKey.dmg"
  name "TelunKey"
  desc "全局快捷键应用启动与窗口切换工具"
  homepage "https://github.com/telungit/TelunKey"

  auto_updates true
  depends_on macos: :sonoma

  preflight_steps do
    run "/usr/bin/osascript",
        args:         ["-e", 'tell application id "com.telunkey.TelunKey" to quit'],
        must_succeed: false
    terminate_process "TelunKey", match: :name, attempts: 3, must_succeed: false
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
