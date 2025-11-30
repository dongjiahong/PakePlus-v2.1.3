# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

PakePlus (PacBao) 是一个基于 Rust Tauri 的桌面应用打包工具，可以将任何网页、Vue/React 项目打包成桌面和移动应用。项目采用 Tauri v2 + Vue 3 架构，支持 Mac、Windows、Linux 桌面平台以及 Android、iOS 移动平台。

**重要说明**：前端代码未开源，仅包含已编译的 `dist` 目录。

## 技术栈

### 后端 (Rust/Tauri)
- **Tauri 2.x**: 核心框架
- **Rust 1.63+**: 后端语言
- **依赖库**:
  - `warp`: 本地静态文件服务器
  - `tokio`: 异步运行时
  - `zip`: 文件压缩/解压
  - `machine-uid`: 机器唯一标识
  - `notify-rust`: 系统通知

### 前端 (已编译)
- **Vue 3** + **TypeScript**
- **Vite 6**: 构建工具
- **Element Plus**: UI 组件库
- **Pinia**: 状态管理
- **CodeMirror 6**: 代码编辑器

## 常用命令

### 开发环境
```bash
# 安装依赖
pnpm i

# 本地开发 (需要前端源码)
pnpm run dev

# Tauri 开发模式 (右键打开调试模式)
pnpm run tauri:dev

# 预览 Tauri 应用
pnpm tauri preview
```

### 构建打包
```bash
# 完整构建 (生成生产版本)
pnpm run build

# Tauri 生产构建
pnpm run tauri:build

# Tauri 调试构建
pnpm run tauri:debug

# 生成应用图标
pnpm run icon
```

### 文档相关
```bash
# 启动文档开发服务器
pnpm run docs:dev

# 构建文档
pnpm run docs:build

# 预览文档
pnpm run docs:preview
```

### Cargo 相关
```bash
# 更新 Tauri 依赖
pnpm run "update tauri"

# 清理 Cargo 缓存
pnpm run rm:cache
```

## 架构设计

### Rust 后端架构 (`src-tauri/`)

```
src-tauri/
├── src/
│   ├── lib.rs              # Tauri 应用主入口，注册插件和命令
│   ├── main.rs             # 程序启动入口
│   ├── command/
│   │   ├── mod.rs          # 命令模块导出
│   │   ├── cmds.rs         # Tauri 命令实现
│   │   └── model.rs        # 数据模型定义
│   └── utils/
│       ├── mod.rs          # 工具模块导出
│       └── init.rs         # 应用初始化逻辑
├── Cargo.toml              # Rust 依赖配置
└── tauri.conf.json         # Tauri 配置文件
```

### 核心 Tauri 命令

所有命令定义在 `src-tauri/src/command/cmds.rs`，通过 `tauri::generate_handler!` 注册：

**预览与窗口管理**
- `preview_from_config`: 根据配置创建/调整预览窗口
- `open_url`: 打开外部 URL
- `open_devtools`: 打开开发者工具

**本地服务器**
- `start_server`: 启动本地静态文件服务器 (使用 warp)
- `stop_server`: 停止服务器
- `find_port`: 查找可用端口

**文件操作**
- `compress_folder`: 压缩文件夹为 zip
- `decompress_file`: 解压 zip 文件
- `download_file`: 下载文件并报告进度

**构建命令**
- `windows_build`: Windows 平台构建
- `macos_build`: macOS 平台构建
- `linux_build`: Linux 平台构建
- `build_local`: 本地快速构建

**系统功能**
- `get_machine_uid`: 获取机器唯一标识
- `run_command`: 执行系统命令
- `get_env_var`: 获取环境变量
- `get_exe_dir`: 获取可执行文件目录
- `notification`: 发送系统通知
- `update_init_rs`: 更新初始化配置

### Tauri 插件

项目使用以下 Tauri 官方插件 (在 `lib.rs` 中注册):
- `tauri-plugin-os`: 系统信息
- `tauri-plugin-fs`: 文件系统访问
- `tauri-plugin-dialog`: 原生对话框
- `tauri-plugin-http`: HTTP 请求
- `tauri-plugin-process`: 进程管理
- `tauri-plugin-clipboard-manager`: 剪贴板
- `tauri-plugin-updater`: 应用更新
- `tauri-plugin-store`: 本地存储

### 前端编译配置

`vite.config.ts` 关键配置：
- **开发服务器**: 端口 1420，HMR 端口 1421
- **路径别名**: `@` → `src/`, `@root` → `./`
- **代码分割**: 分离 vue、element-plus、pinia、codemirror、axios 等大型库
- **构建优化**: 使用 visualizer 分析打包体积

### GitHub Actions 构建

`.github/workflows/build.yml` 支持多平台构建：
- **macOS**: x86_64 和 aarch64 (M1/M2)
- **Windows**: x86_64 和 aarch64
- **Linux**: x86_64 和 aarch64

构建流程：
1. 安装 Rust target
2. 安装 pnpm 和 Node.js 20
3. 生成应用图标 (`pnpm tauri icon`)
4. 平台特定依赖 (Linux: libwebkit2gtk, libappindicator)
5. Tauri 构建和签名
6. 上传 release artifacts

## 开发注意事项

### 前端开发限制
- 前端源码不可用，只能修改已编译的 `dist` 目录
- 如需修改前端功能，需要通过 Tauri 命令实现

### Rust 开发
- 添加新命令时，需在 `cmds.rs` 实现并在 `lib.rs` 的 `generate_handler!` 中注册
- 使用 `#[tauri::command]` 宏标记命令函数
- 异步操作使用 `async fn`，返回 `Result<T, String>`

### 构建要求
- **Rust**: >= 1.63
- **Node.js**: >= 16 (推荐 20)
- **包管理器**: pnpm
- **平台特定**:
  - macOS: Xcode Command Line Tools
  - Windows: Visual Studio Build Tools
  - Linux: libwebkit2gtk、libappindicator

### 图标生成
```bash
# 从 app-icon.png 生成多尺寸图标
pnpm run icon

# macOS 特殊处理 (scripts/creatIcon.cjs)
node ./scripts/creatIcon.cjs
```

### 本地打包特性
- 支持 30 秒快速本地打包
- 不需要 GitHub Token
- 调用 `build_local` 命令实现

### 安全配置
- CSP 策略配置在 `tauri.conf.json`
- 资源协议范围广泛 (允许访问系统各目录)
- 允许 `unsafe-inline` 和 `unsafe-eval` (支持动态 JS 注入)

## 项目特色功能

1. **JS 注入**: 支持自定义 JavaScript 注入到打包应用
2. **静态文件打包**: 支持将 Vue/React 编译产物直接打包
3. **多平台支持**: 桌面端 (Tauri) + 移动端 (原生框架)
4. **云端打包**: 通过 GitHub Actions 实现零本地依赖
5. **调试模式**: 预览和发布阶段都支持 DevTools
6. **国际化**: 自动跟随系统语言

## 文档资源
- 官方文档: https://pakeplus.com/guide/
- Tauri 文档: https://tauri.app/
- 仓库地址: https://github.com/Sjj1024/PakePlus
