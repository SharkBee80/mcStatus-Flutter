# Minecraft Server Status

一个跨平台的Minecraft服务器状态监控应用，支持实时查询服务器在线状态、玩家数量、版本信息等。

## 📱 应用截图

[//]: # (<div style="display: flex; justify-content: space-around;">)

[//]: # (  <img src="assets/img/screenshots/home.png" alt="主页" width="200"/>)

[//]: # (  <img src="assets/img/screenshots/server_info.png" alt="服务器详情" width="200"/>)

[//]: # (  <img src="assets/img/screenshots/settings.png" alt="设置" width="200"/>)

[//]: # (</div>)

## 🌟 功能特性

- **实时监控**: 实时获取Minecraft服务器状态信息
- **多服务器管理**: 添加、编辑、删除多个服务器
- **状态展示**: 显示在线人数、版本、延迟等详细信息
- **跨平台支持**: 支持Android、iOS、Windows、macOS、Linux
- **离线模式**: 本地保存服务器列表，无网络时也可查看
- **个性化设置**: 丰富的UI和功能设置选项
- **激活机制**: 应用激活验证保护

## 🚀 快速开始

### 系统要求

- Flutter 3.0+
- Dart 2.17+
- Android API 21+ / iOS 12+ / Windows 10+ / macOS 10.15+ / Linux

### 安装步骤

1. 克隆项目:
```bash
git clone <repository-url>
cd Minecraft_Server_Status
```

2. 安装依赖:
```bash
flutter pub get
```

3. 运行应用:
```bash
flutter run
```

### 构建发布版本

- **Android**:
```bash
flutter build apk
```

- **iOS**:
```bash
flutter build ios
```

- **Windows**:
```bash
flutter build windows
```

## 🛠️ 核心功能

### 1. 服务器管理
- 添加新服务器（名称、地址）
- 编辑现有服务器信息
- 删除不需要的服务器
- 拖拽排序服务器列表

### 2. 状态监控
- 实时Ping服务器获取状态
- 显示在线玩家数量
- 展示服务器版本信息
- 显示连接延迟
- 查看在线玩家列表

### 3. 设置功能
~~- **服务器设置**: 自动刷新、刷新间隔、连接超时~~

~~- **UI设置**: 主题切换、语言选择、卡片列数~~

~~- **通知设置**: 启用通知、离线提醒~~

~~- **高级设置**: 调试模式、屏幕常亮、动画速度~~

## 📁 项目结构

```
lib/
├── core/              # 核心功能模块
├── hive/              # 本地数据存储
├── models/            # 数据模型
├── pages/             # 页面组件
├── provider/          # 状态管理
├── ui/                # UI组件
├── utils/             # 工具类
└── main.dart          # 应用入口
```

## 🔧 技术栈

- **框架**: Flutter + Dart
- **状态管理**: Provider
- **本地存储**: Hive
- **网络通信**: [**dart_minecraft**](https://pub.dev/packages/dart_minecraft)
- **UI组件**: 自定义组件 + 第三方库

## 🔐 激活机制

应用采用激活码验证机制，首次使用需要输入激活码才能正常使用所有功能。
- **`6666`**

## 🤝 贡献

欢迎提交Issue和Pull Request来改进这个项目。

## 📄 许可证

本项目仅供个人学习和研究使用，请勿用于商业用途。

## 📞 联系方式

如有问题，请联系项目维护者。