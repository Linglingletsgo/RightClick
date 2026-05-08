<p align="center">
  <img src="RightClick/Assets.xcassets/AppIcon.appiconset/icon_256x256.png" alt="RightClick logo" width="128">
</p>

# RightClick

RightClick is a minimal macOS Finder context menu app for personal file operations. It installs a Finder Sync extension and adds practical actions to watched folders, starting with the current user's Home folder.

[简体中文说明](README.zh-CN.md)

## Features

- `Copy > Path`: copy selected file or folder paths. Multiple selections are copied one path per line.
- `Copy > Name`: copy selected file or folder names. Multiple selections are copied one name per line.
- `New > ...`: create Markdown, Text, Swift, Word, Excel, or PowerPoint files in the current Finder folder.
- `Open With > ...`: open selected files with configured apps, including TextEdit and Terminal by default.
- `Open Folder > ...`: open configured folders, with `Projects` as the default entry.
- `Show Hidden Folders` / `Hide Hidden Folders`: toggle Finder's hidden-item display from a blank-area folder menu by posting Finder's `Shift-Command-.` shortcut.
- Settings window: manage watched folders, menu item switches, new file templates, Open With apps, and Open Folder entries.

## Menu Rules

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

Selected-item menus do not show `New`. Blank-area folder menus do not show `Copy` or `Open With`.

## Install

1. Download `RightClick-0.2.1.dmg` from the GitHub release.
2. Open the DMG and drag `RightClick.app` into `Applications`.
3. Launch `RightClick.app`.
   - RightClick is not notarized yet. If macOS blocks the first launch, right-click `RightClick.app` in `Applications`, choose `Open`, then choose `Open` again in the confirmation dialog.
   - If macOS still blocks it, open System Settings > Privacy & Security and use `Open Anyway` for RightClick.
4. Open System Settings > General > Login Items & Extensions > Extensions, choose `RightClick`, enable `File Provider`, then click `Done`.
5. Open System Settings > Privacy & Security > Accessibility, add `/Applications/RightClick.app`, and enable it. This is required for `Show/Hide Hidden Folders`, which posts Finder's native `Shift-Command-.` shortcut.
6. Restart Finder if the menu does not appear immediately.

## Usage

- Use Finder inside your Home folder or folders added in RightClick settings.
- Right-click selected items to copy paths, copy names, or open with configured apps.
- Right-click blank space inside a watched folder to create new files.
- Use `Open Folder` to jump to configured folders.
- The hidden-files toggle uses Finder's native `Shift-Command-.` shortcut through the background command path. macOS may ask for Accessibility permission for `RightClick` the first time this shortcut is posted.

## Build

```bash
xcodebuild -project RightClick.xcodeproj -scheme RightClick -configuration Release -derivedDataPath .build/xcode-release build
```

Package a DMG:

```bash
./script/package_dmg.sh
```

The DMG is written to `dist/RightClick-0.2.1.dmg`.

## Notes

- RightClick is built for personal use and is not designed as a public plugin platform.
- The app uses macOS Finder Sync, so menus only appear inside watched folders.
- The app is locally signed for personal use but is not Apple notarized. For broader public distribution, use a Developer ID certificate and Apple notarization.
- Version `0.2.1` targets macOS 26.
