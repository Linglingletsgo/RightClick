<p align="center">
  <img src="RightClick/Assets.xcassets/AppIcon.appiconset/icon_256x256.png" alt="RightClick logo" width="128">
</p>

# RightClick

RightClick is a minimal macOS Finder context menu app for personal file operations. It installs a Finder Sync extension and adds practical actions to watched folders, starting with the current user's Home folder.

RightClick 是一个极简的 macOS Finder 右键菜单工具，用于个人常用文件操作。它通过 Finder Sync 扩展工作，默认监听当前用户的 Home 目录及其子目录。

## Features / 功能

- `Copy > Path`: copy selected file or folder paths. Multiple selections are copied one path per line.
- `Copy > Name`: copy selected file or folder names. Multiple selections are copied one name per line.
- `New > ...`: create empty Markdown, Text, Swift, Word, Excel, or PowerPoint files in the current Finder folder.
- `Open With > ...`: open selected files with configured apps, including TextEdit and Terminal by default.
- `Open Folder > ...`: open configured folders, with `Projects` as the default entry.
- `Show Hidden Folders` / `Hide Hidden Folders`: toggle Finder's hidden-file display from a blank-area folder menu.
- Settings window: manage watched folders, menu item switches, new file templates, Open With apps, and Open Folder entries.

- `Copy > Path`：复制选中文件或文件夹的完整路径，多选时每行一个路径。
- `Copy > Name`：复制选中文件或文件夹名称，多选时每行一个名称。
- `New > ...`：在当前 Finder 文件夹中新建 Markdown、Text、Swift、Word、Excel、PowerPoint 文件。
- `Open With > ...`：用预设 App 打开选中文件，默认包含 TextEdit 和 Terminal。
- `Open Folder > ...`：打开常用文件夹，默认包含 `Projects`。
- `Show Hidden Folders` / `Hide Hidden Folders`：在文件夹空白处右键切换 Finder 隐藏项目显示。
- 设置窗口：管理监听目录、菜单开关、新建文件模板、Open With App 和 Open Folder 条目。

## Menu Rules / 菜单规则

When right-clicking selected files or folders:

- `Copy > Path`
- `Copy > Name`
- `Open With > TextEdit`
- `Open With > Terminal`
- `Open Folder > Projects`

When right-clicking a blank area inside a watched folder:

- `New > Markdown File`
- `New > Text File`
- `New > Swift File`
- `New > Word File`
- `New > Excel File`
- `New > PowerPoint File`
- `Open Folder > Projects`
- `Show Hidden Folders` or `Hide Hidden Folders`

选中文件或文件夹右键时显示复制、打开方式和打开文件夹功能，不显示新建文件。文件夹空白处右键时显示新建文件、打开文件夹和隐藏项目开关，不显示复制和打开方式。

## Install / 安装

1. Download `RightClick-0.1.0.dmg` from the GitHub release.
2. Open the DMG and drag `RightClick.app` into `Applications`.
3. Launch `RightClick.app`.
4. Open System Settings, go to Login Items & Extensions, then enable the `RightClick` Finder extension.
5. Restart Finder if the menu does not appear immediately.

1. 从 GitHub release 下载 `RightClick-0.1.0.dmg`。
2. 打开 DMG，将 `RightClick.app` 拖入 `Applications`。
3. 启动 `RightClick.app`。
4. 打开系统设置，在“登录项与扩展”中启用 `RightClick` 的 Finder 扩展。
5. 如果右键菜单没有立即出现，重启 Finder。

## Usage / 使用

- Use Finder inside your Home folder or folders added in RightClick settings.
- Right-click selected items to copy paths, copy names, or open with configured apps.
- Right-click blank space inside a watched folder to create new files.
- Use `Open Folder` to jump to configured folders.
- The hidden-files toggle changes Finder's global hidden item setting and restarts Finder.

- 在 Home 目录或 RightClick 设置中添加的目录内使用 Finder。
- 选中文件或文件夹后右键，可复制路径、复制名称或用预设 App 打开。
- 在监听文件夹空白处右键，可新建文件。
- 使用 `Open Folder` 快速打开常用文件夹。
- 隐藏项目开关会修改 Finder 的全局隐藏项目设置，并重启 Finder。

## Build / 构建

```bash
xcodebuild -project RightClick.xcodeproj -scheme RightClick -configuration Release -derivedDataPath .build/xcode-release build
```

Package a DMG:

```bash
./script/package_dmg.sh
```

The DMG is written to `dist/RightClick-0.1.0.dmg`.

DMG 输出位置为 `dist/RightClick-0.1.0.dmg`。

## Notes / 说明

- RightClick is built for personal use and is not designed as a public plugin platform.
- The app uses macOS Finder Sync, so menus only appear inside watched folders.
- Version `0.1.0` targets macOS 26.

- RightClick 面向个人使用，不做插件系统或大众分发平台。
- 应用基于 macOS Finder Sync，因此菜单只会出现在监听目录内。
- `0.1.0` 版本目标系统为 macOS 26。
