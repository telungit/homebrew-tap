cask "telunkey" do
  version "2.0.2"
  sha256 "d9a3ccffd8bf825023ef50c4716c9a2ebc895d21bf939c6df718727cf2808281"

  url "https://github.com/telungit/TelunKey/releases/download/v#{version}/TelunKey.dmg"
  name "TelunKey"
  desc "全局快捷键应用启动与窗口切换工具"
  homepage "https://github.com/telungit/TelunKey"

  auto_updates true
  depends_on macos: :sonoma

  app "TelunKey.app"

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
