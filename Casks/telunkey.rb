cask "telunkey" do
  version "2.0.3"
  sha256 "0dec75d32c11cf74382a52dc8ad462034bb0de9fb036c549a83ae639fe7b5bb5"

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
    当前发行包尚未经过 Apple 公证；安装时会自动移除 TelunKey.app 的隔离标记。
    首次运行需要授予辅助功能权限；窗口缩略图另需屏幕录制权限。
  EOS
end
