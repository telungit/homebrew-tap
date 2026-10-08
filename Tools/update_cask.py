#!/usr/bin/env python3
"""从公开正式 Release 校验安装包并更新 Homebrew 配方。"""

import argparse
import hashlib
import json
from pathlib import Path
import re
import sys
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


REPOSITORY = "telungit/TelunKey"
CASK_PATH = Path(__file__).resolve().parents[1] / "Casks" / "telunkey.rb"
TAG_PATTERN = r"v([0-9]+(?:\.[0-9]+){1,3})"


def open_url(url):
    return urlopen(Request(url, headers={"User-Agent": "TelunKey-Homebrew"}), timeout=60)


def release_asset(release, name, tag):
    matches = [asset for asset in release["assets"] if asset["name"] == name]
    if len(matches) != 1:
        raise ValueError(f"正式 Release 必须包含唯一的 {name}")
    asset = matches[0]
    expected = f"https://github.com/{REPOSITORY}/releases/download/{tag}/{name}"
    if asset["browser_download_url"] != expected:
        raise ValueError(f"{name} 的下载地址与指定仓库、标签不一致")
    return asset


def update(tag):
    original = CASK_PATH.read_text(encoding="utf-8")
    versions = re.findall(r'^  version "([0-9]+(?:\.[0-9]+){1,3})"$', original, flags=re.M)
    hashes = re.findall(r'^  sha256 "([0-9a-f]{64})"$', original, flags=re.M)
    if len(versions) != 1 or len(hashes) != 1:
        raise ValueError("配方中必须存在唯一的固定版本和 SHA-256")
    current_version = versions[0]
    current_checksum = hashes[0]
    if tag and not re.fullmatch(TAG_PATTERN, tag):
        raise ValueError("标签必须使用 v<版本号> 格式，例如 v2.0.1")
    endpoint = f"tags/{tag}" if tag else "latest"
    with open_url(f"https://api.github.com/repos/{REPOSITORY}/releases/{endpoint}") as response:
        release = json.load(response)
    if release.get("draft") or release.get("prerelease"):
        raise ValueError("只允许同步公开正式 Release")
    released_tag = release["tag_name"]
    match = re.fullmatch(TAG_PATTERN, released_tag)
    if not match or (tag and tag != released_tag):
        raise ValueError("Release 标签格式或版本与请求不一致")
    version = match.group(1)
    # 补齐版本分段后比较，避免将 2.0.10 误判为早于 2.0.9。
    release_parts = tuple(map(int, version.split(".")))
    current_parts = tuple(map(int, current_version.split(".")))
    if release_parts + (0,) * (4 - len(release_parts)) < current_parts + (0,) * (4 - len(current_parts)):
        raise ValueError(f"拒绝将配方从 {current_version} 回退到 {version}")
    asset = release_asset(release, "TelunKey.dmg", released_tag)

    digest = hashlib.sha256()
    size = 0
    with open_url(asset["browser_download_url"]) as response:
        while chunk := response.read(1024 * 1024):
            digest.update(chunk)
            size += len(chunk)
    if size == 0 or size != asset["size"]:
        raise ValueError("DMG 下载大小与 Release 资产不一致")
    checksum = digest.hexdigest()
    if version == current_version and checksum != current_checksum:
        raise ValueError("同一版本的 DMG 已发生变化，请发布新版本后再同步")
    if asset.get("digest") and asset["digest"] != f"sha256:{checksum}":
        raise ValueError("DMG 的 SHA-256 与 GitHub 资产摘要不一致")

    checksum_asset = release_asset(release, "TelunKey.dmg.sha256", released_tag)
    with open_url(checksum_asset["browser_download_url"]) as response:
        checksum_text = response.read(4096).decode("utf-8")
    published_checksum = re.match(r"\A([0-9a-fA-F]{64})\s+", checksum_text)
    if not published_checksum or published_checksum.group(1).lower() != checksum:
        raise ValueError("DMG 的 SHA-256 与发布的校验文件不一致")

    updated, versions = re.subn(r'^  version "[^"\n]+"$', f'  version "{version}"', original, flags=re.M)
    updated, hashes = re.subn(r'^  sha256 "[0-9a-f]{64}"$', f'  sha256 "{checksum}"', updated, flags=re.M)
    if versions != 1 or hashes != 1:
        raise ValueError("配方中必须存在唯一的固定版本和 SHA-256")
    if updated != original:
        CASK_PATH.write_text(updated, encoding="utf-8")
        print(f"已更新配方：{version}，SHA-256 {checksum}")
    else:
        print(f"配方已是 {version}，安装包校验通过，无需修改")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tag", help="指定正式 Release 标签，默认使用最新版本")
    args = parser.parse_args()
    try:
        update(args.tag)
    except (ValueError, KeyError, TypeError, OSError, HTTPError, URLError) as error:
        print(f"同步失败：{error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
