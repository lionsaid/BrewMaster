# BrewMaster

<div style="display: flex; justify-content: space-around; margin: 20px 0;">
<img src="docs/screenshots/dashboard.png" width="200" alt="Dashboard">
<img src="docs/screenshots/cleanup.png" width="200" alt="Cleanup"> 
<img src="docs/screenshots/discover.png" width="200" alt="Discover">
<img src="docs/screenshots/health.png" width="200" alt="Health">
</div>
<div style="display: flex; justify-content: space-around; margin: 20px 0;">
<img src="docs/screenshots/installed.png" width="200" alt="Installed">
<img src="docs/screenshots/recommended.png" width="200" alt="Recommended">
<img src="docs/screenshots/services.png" width="200" alt="Services">
<img src="docs/screenshots/updates.png" width="200" alt="Updates">
</div>

> **BrewMaster** - 优雅、强大的 Homebrew 图形化客户端，专为 macOS 设计

[![Flutter](https://img.shields.io/badge/Flutter-3.22+-blue.svg)](https://flutter.dev)
[![macOS](https://img.shields.io/badge/macOS-13+-green.svg)](https://www.apple.com/macos)
[![License](https://img.shields.io/badge/License-AGPL%203.0-red.svg)](LICENSE)

## ✨ 特性

- 🎯 **桌面级体验** - 以直观的图形界面管理 Homebrew：安装、卸载、更新、服务、清理、健康检查
- 🎨 **现代设计** - 玻璃拟态（Glassmorphism）+ 统一主题体系，兼具美观与信息密度
- ⚡ **实时反馈** - 实时命令输出与进度反馈，关键操作可视化且可追踪
- 🌍 **多语言支持** - 支持中文、英文等多种语言
- 🔍 **智能搜索** - 强大的包搜索与发现功能
- 📊 **系统监控** - 实时系统健康检查与清理建议

## 🚀 快速开始

### 系统要求

- **操作系统**: macOS 13+ (推荐)
- **依赖**: 已安装 Homebrew
- **架构**: Apple Silicon (M1/M2/M3) 或 Intel x86

### 下载安装

#### 方式一：直接下载
- **下载链接**: [BrewMaster-universal.dmg](dist/BrewMaster-universal.dmg) (约 21 MB)
- **支持架构**: Apple Silicon 与 Intel 双架构

#### 安装步骤
1. 双击打开 DMG 文件
2. 将 BrewMaster 拖拽到「应用程序」文件夹
3. 首次启动时，如果被系统阻止，右键图标选择「打开」即可

#### 文件校验 (可选)
```bash
shasum -a 256 dist/BrewMaster-universal.dmg
# 期望值：
# f901294104010789e925b5a9a9239424fad4d734e97f8901c6963f1a6f993a6c
```

### 安装 Homebrew (如果未安装)

#### 官方安装命令
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### 环境初始化

**Apple Silicon (M1/M2/M3)**:
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

**Intel x86**:
```bash
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/usr/local/bin/brew shellenv)"
```

#### 验证安装
```bash
brew --version
brew doctor
```

#### 安装 Xcode Command Line Tools (如需要)
```bash
xcode-select --install
```

> 💡 **提示**: 完成以上步骤后，重新打开 BrewMaster，确保 `brew` 已在 `PATH` 中即可正常使用。

## 📱 功能预览

| 功能模块 | 描述 | 截图 |
|---------|------|------|
| **仪表盘** | 系统概览、统计信息、快速操作 | ![Dashboard](docs/screenshots/dashboard.png) |
| **已安装** | 管理已安装的包、查看详情 | ![Installed](docs/screenshots/installed.png) |
| **发现** | 搜索和发现新的包 | ![Discover](docs/screenshots/discover.png) |
| **推荐** | 精选推荐包 | ![Recommended](docs/screenshots/recommended.png) |
| **更新** | 管理包更新 | ![Updates](docs/screenshots/updates.png) |
| **服务** | 管理 Homebrew 服务 | ![Services](docs/screenshots/services.png) |
| **系统健康** | 系统健康检查 | ![Health](docs/screenshots/health.png) |
| **系统清理** | 清理系统缓存和旧文件 | ![Cleanup](docs/screenshots/cleanup.png) |

## 🔧 核心功能

### 📦 包管理
- **安装管理**: 列出 Formulae/Casks，详情页支持历史版本、文件列表、选项查看
- **操作支持**: 卸载/重装/Pin/Unpin，带确认与反馈
- **批量操作**: 支持批量安装、卸载、更新

### 🔍 搜索与发现
- **智能搜索**: 同步 `brew search`，结果卡片一键安装
- **实时日志**: 安装过程实时显示日志
- **推荐系统**: 基于热门度和实用性的智能推荐

### 🔄 更新中心
- **过期检测**: 展示过期项、单个/批量/全部升级
- **进度跟踪**: 进度条+ETA 估算，依赖影响提示
- **变更日志**: 提供变更日志链接

### ⚙️ 服务管理
- **服务列表**: `brew services list` 可视化
- **操作控制**: Start/Stop/Restart，忙碌状态与结果反馈
- **状态监控**: 实时服务状态监控

### 📊 仪表盘概览
- **系统统计**: 已安装统计、更新数、系统健康
- **清理建议**: 可清理空间、服务状态，一目了然
- **快速操作**: 常用功能的快速访问

### 🧹 系统清理
- **分类清理**: 按类别（缓存/旧版本/未链接等）展开选择
- **容量统计**: 汇总已选容量，底部固定"立即清理"
- **安全确认**: 清理前确认机制

### 🏥 系统健康
- **逐项检查**: 动画式检查流程（待检查→进行中→结果）
- **实时日志**: 带实时日志流
- **检查项目**: brew doctor、Prefix、PATH、Xcode CLT、缺失依赖等

## 🏗️ 项目架构

```
lib/
├── main.dart                    # 应用入口、全局背景与 builder
├── app/
│   ├── app_theme.dart          # 主题配置
│   └── app_colors.dart         # 配色方案
├── core/
│   ├── services/
│   │   └── brew_service.dart   # 所有 brew 调用与容错
│   ├── models/                 # 数据模型
│   │   ├── package.dart
│   │   ├── outdated_package.dart
│   │   └── service_item.dart
│   └── widgets/                # 通用组件
│       ├── app_card.dart
│       ├── gradient_button.dart
│       └── search_input.dart
├── features/                   # 功能模块
│   ├── dashboard/             # 仪表盘
│   ├── packages/              # 已安装列表与详情
│   ├── search/                # 发现与搜索
│   ├── updates/               # 更新管理
│   ├── services/              # 服务管理
│   ├── health/                # 系统健康检查
│   ├── cleanup/               # 系统清理
│   ├── recommend/             # 推荐页
│   └── home/                  # 主布局
└── l10n/                      # 国际化
    ├── app_en.arb
    ├── app_zh.arb
    └── app_localizations.dart
```

## 🖥️ macOS 桌面端特性

### 命令执行与权限
- 项目依赖 `dart:io` 调用系统 `brew`
- 在 macOS Debug 模式下关闭沙盒
- `macos/Runner/DebugProfile.entitlements` 中已将 `com.apple.security.app-sandbox` 设为 `<false/>`

### 窗口与材质
- `macos/Runner/MainFlutterWindow.swift`: 最小窗口尺寸、窗口行为配置
- 视觉风格: `FrostCard` 通过 `BackdropFilter` + 半透明容器实现玻璃拟态

## 🛠️ 开发指南

### 环境要求

- **Flutter**: 3.22+ (推荐)
- **macOS 桌面支持**: 已启用
- **系统**: macOS 13+ (推荐)
- **Homebrew**: 已安装 (`brew --version`)

### 本地开发

```bash
# 克隆项目
git clone <repository-url>
cd brew_master

# 安装依赖
flutter pub get

# 运行项目
flutter run -d macos
```

### 首次启用桌面支持

```bash
flutter config --enable-macos-desktop
```

### 构建发布版本

```bash
flutter build macos
```

## 🔧 常见问题

### Homebrew 远端 API 异常
如果出现 `Cannot download non-corrupt https://formulae.brew.sh/api/formula.jws.json!` 错误：
- 程序会自动以 `HOMEBREW_NO_INSTALL_FROM_API=1`、`HOMEBREW_NO_GITHUB_API=1` 重试
- `brew outdated` / `brew info` 失败时，启用纯文本回退解析，避免崩溃

### brew doctor 有 Warning
- 健康页使用 `allowNonZero` 并解析输出文本，不会中断检查流程
- 所有 Warning 都会在界面上显示，方便用户查看和修复

### 进度显示
- macOS 使用 `script -q /dev/null -c` 启动 PTY，实时流输出
- 支持 `brew install/upgrade` 等长时间操作的进度显示

## 🎨 设计语言

### 视觉特色
- **统一玻璃材质**: 导航/卡片/提示都采用玻璃拟态设计
- **高信息密度**: 合理的信息布局，避免界面拥挤
- **呼吸感设计**: 适当的留白，提升视觉体验

### 交互亮点
- **实时反馈**: 实时日志、状态动画（健康检查、安装/升级）
- **响应式布局**: `SliverGridDelegateWithMaxCrossAxisExtent` + `Wrap`/`LayoutBuilder`
- **流畅动画**: 页面切换、状态变化都有流畅的动画效果

## 🗺️ 路线图

### 近期计划
- [ ] 推荐内容智能化：安装画像、热门趋势
- [ ] 历史版本管理增强：一键 `extract + install` 可视化
- [ ] 更多批量操作：Pin/Unpin、多选清理/升级

### 长期规划
- [ ] 图标缓存与离线降级
- [ ] 插件系统支持
- [ ] 云端配置同步
- [ ] 更多平台支持

## 🤝 贡献指南

我们欢迎所有形式的贡献！

### 如何贡献
1. **Fork** 本项目
2. 创建你的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交你的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启一个 **Pull Request**

### 贡献类型
- 🐛 **Bug 报告**: 提交 Issue 描述问题
- 💡 **功能建议**: 提出新功能想法
- 📝 **文档改进**: 改进文档和注释
- 🔧 **代码贡献**: 提交代码修复或新功能

## 📄 许可证

本项目采用 **GNU AFFERO GENERAL PUBLIC LICENSE Version 3** 许可证。

查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者！

---

<div align="center">
Made with ❤️ for the Homebrew community
</div>
