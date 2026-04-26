<p align="center">
  <img src="RightClick/Assets.xcassets/AppIcon.appiconset/icon_256x256.png" alt="RightClick logo" width="128">
</p>

# RightClick

RightClick 是一个极简的 macOS Finder 右键菜单工具，用于个人常用文件操作。它通过 Finder Sync 扩展工作，默认监听当前用户的 Home 目录及其子目录。

[English README](README.md)

## 功能

- `Copy > Path`：复制选中文件或文件夹的完整路径，多选时每行一个路径。
- `Copy > Name`：复制选中文件或文件夹名称，多选时每行一个名称。
- `New > ...`：在当前 Finder 文件夹中新建 Markdown、Text、Swift、Word、Excel、PowerPoint 文件。
- `Open With > ...`：用预设 App 打开选中文件，默认包含 TextEdit 和 Terminal。
- `Open Folder > ...`：打开常用文件夹，默认包含 `Projects`。
- `Show Hidden Folders` / `Hide Hidden Folders`：在文件夹空白处右键通过 Finder 原生 `Shift-Command-.` 快捷键切换隐藏项目显示。
- 设置窗口：管理监听目录、菜单开关、新建文件模板、Open With App 和 Open Folder 条目。

## 菜单规则

选中文件或文件夹右键时显示：

- `Copy > Path`
- `Copy > Name`
- `Open With > TextEdit`
- `Open With > Terminal`
- `Open Folder > Projects`

文件夹空白处右键时显示：

- `New > Markdown File`
- `New > Text File`
- `New > Swift File`
- `New > Word File`
- `New > Excel File`
- `New > PowerPoint File`
- `Open Folder > Projects`
- `Show Hidden Folders` 或 `Hide Hidden Folders`

选中文件或文件夹右键不显示 `New`。文件夹空白处右键不显示 `Copy` 或 `Open With`。

## 安装

1. 从 GitHub release 下载 `RightClick-0.1.0.dmg`。
2. 打开 DMG，将 `RightClick.app` 拖入 `Applications`。
3. 启动 `RightClick.app`。
4. 打开系统设置，在“登录项与扩展”中启用 `RightClick` 的 Finder 扩展。
5. 如果右键菜单没有立即出现，重启 Finder。

## 使用

- 在 Home 目录或 RightClick 设置中添加的目录内使用 Finder。
- 选中文件或文件夹后右键，可复制路径、复制名称或用预设 App 打开。
- 在监听文件夹空白处右键，可新建文件。
- 使用 `Open Folder` 快速打开常用文件夹。
- 隐藏项目开关会模拟 Finder 原生 `Shift-Command-.` 快捷键。macOS 首次发送该快捷键时可能要求授予 Accessibility 权限。

## 构建

```bash
xcodebuild -project RightClick.xcodeproj -scheme RightClick -configuration Release -derivedDataPath .build/xcode-release build
```

打包 DMG：

```bash
./script/package_dmg.sh
```

DMG 输出位置为 `dist/RightClick-0.1.0.dmg`。

## 说明

- RightClick 面向个人使用，不做插件系统或大众分发平台。
- 应用基于 macOS Finder Sync，因此菜单只会出现在监听目录内。
- `0.1.0` 版本目标系统为 macOS 26。
