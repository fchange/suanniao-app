# suanniao-app

一个基于 Swift、AppKit 和 Swift Package Manager 的 macOS 菜单栏提醒应用。点击菜单栏图标会弹出“蒜鸟蒜鸟”提醒面板并播放本地音频，支持在设置页调整外观、颜色、缩放和音量。

## 功能

- 菜单栏常驻，左键触发提醒，右键打开菜单
- 浮层提醒面板，支持品牌图标、字体、透明度和窗口缩放
- 本地音频提醒，支持自定义音量
- 设置页可实时预览提醒效果
- 已内置菜单栏图标、品牌图标、Dock 图标和 `.icns` 资源

## 技术栈

- Swift 6
- AppKit
- SwiftUI
- AVFoundation
- Swift Package Manager

## 环境要求

- macOS 14+
- Xcode 16+ 或兼容的 Swift 6 工具链

## 本地开发

```bash
make build
make run
```

构建产物：

```text
build/蒜鸟蒜鸟.app
```

安装到本机：

```bash
make install
```

安装到指定目录：

```bash
make install INSTALL_DIR=/Applications
```

生成发布包：

```bash
make package-zip VERSION=0.0.1
make package-dmg VERSION=0.0.1
```

## 资源文件

音频资源：

```text
Resources/Audio/suanniao.mp3
Resources/Audio/suanniao.m4a
```

图标资源：

- `Resources/BrandMarkFilledCutout.png`：当前菜单栏图标
- `Resources/BrandMarkOutline.png`：描边版品牌图标
- `Resources/BrandMarkGradient.png`：应用内品牌图
- `Resources/AppIcon.icns`：应用 bundle / Finder 图标
- `Resources/InstallerIcon.icns`：安装包备用图标
- `Resources/IconSources/`：原始图与母版图标

## GitHub Actions

仓库包含两条流水线：

- `ci.yml`：在 `main` 和 Pull Request 上执行 `swift build` 与 `make build`
- `release.yml`：在推送 `v*.*.*` tag 时构建 `.app`，发布 `zip` 和带 `Applications` 快捷方式的 `dmg`

## 版本

当前首个发布版本为 `0.0.1`。

## 签名与分发

- 当前默认生成未签名 `.app`
- Release 默认产出未签名 `zip` / `dmg`
- 本地签名测试可执行：

```bash
codesign --deep --force --sign - build/蒜鸟蒜鸟.app
```

- 正式分发建议使用 Apple Developer 证书签名并完成 notarization
- 未签名版本首次打开时，用户需要在 Finder 中右键应用并选择“打开”，或在“系统设置 -> 隐私与安全性”中选择“仍要打开”
