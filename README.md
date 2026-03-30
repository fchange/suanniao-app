# 蒜鸟蒜鸟

一个使用 Swift + AppKit + Swift Package Manager 实现的 macOS 菜单栏应用。

## 本地构建

```bash
make build
```

生成的应用包路径：

```bash
build/蒜鸟蒜鸟.app
```

## 运行

```bash
make run
```

## 安装

默认安装到 `~/Applications`：

```bash
make install
```

如需安装到其他位置：

```bash
make install INSTALL_DIR=/Applications
```

## 替换音频资源

将音频文件放到：

```text
Resources/Audio/suanniao.mp3
```

也支持：

```text
Resources/Audio/suanniao.m4a
```

## 替换菜单栏图标

放入以下任一文件即可覆盖默认 SF Symbol：

```text
Resources/StatusBarIcon.pdf
Resources/StatusBarIcon.png
```

## 打包与签名注意事项

- 本工程默认可本地构建和运行未签名 `.app`
- 如需在其他机器分发，建议使用 `codesign --deep --force --sign - build/蒜鸟蒜鸟.app` 进行本地签名测试
- 正式分发请使用 Apple Developer 证书签名并按需 notarize
