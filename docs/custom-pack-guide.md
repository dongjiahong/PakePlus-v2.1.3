# 自定义打包使用指南

## 功能说明

这个 GitHub Actions 工作流允许你在云端自动打包任何网页为桌面应用，无需本地安装任何开发环境。

## 使用步骤

### 1. 推送代码到 GitHub

首先确保你的代码已经推送到 GitHub 仓库：

```bash
git add .
git commit -m "添加自定义打包工作流"
git push origin main
```

### 2. 在 GitHub 网页上触发工作流

1. 打开你的 GitHub 仓库页面
2. 点击 **Actions** 标签页
3. 在左侧列表中找到 **Custom Pack** 工作流
4. 点击右侧的 **Run workflow** 按钮

### 3. 填写打包配置

在弹出的表单中填写以下信息：

#### 必填参数

- **应用名称** (app_name)
  - 例如: `YouTube`, `Twitter`, `ChatGPT`
  - 这将是最终生成的应用名称

- **要打包的网页 URL** (app_url)
  - 例如: `https://www.youtube.com`
  - 应用启动后会加载这个网址

- **应用版本号** (app_version)
  - 例如: `0.0.1`, `1.0.0`
  - 默认: `0.0.1`

- **应用标识符** (app_identifier)
  - 例如: `com.example.youtube`
  - 格式: `com.你的名字.应用名`
  - 必须是唯一的反向域名格式

#### 可选参数

- **窗口宽度** (window_width)
  - 默认: `1200`
  - 单位: 像素

- **窗口高度** (window_height)
  - 默认: `800`
  - 单位: 像素

- **启用调试模式** (debug_mode)
  - 默认: `false`
  - 启用后可以右键打开开发者工具

- **选择打包平台** (platforms)
  - 默认: `macos-arm,windows-x64,linux-x64`
  - 可选值:
    - `macos-arm` - macOS Apple 芯片 (M1/M2/M3)
    - `macos-intel` - macOS Intel 芯片
    - `windows-x64` - Windows 64位
    - `windows-arm` - Windows ARM64
    - `linux-x64` - Linux 64位
    - `linux-arm` - Linux ARM64
  - 多个平台用逗号分隔

- **自定义 JS 代码** (inject_js)
  - 可选，用于在页面加载后执行自定义 JavaScript
  - 例如: `console.log('Hello from custom app!');`

### 4. 等待构建完成

- 构建过程大约需要 10-30 分钟（取决于选择的平台数量）
- 可以在 Actions 页面查看实时构建日志

### 5. 下载安装包

构建完成后，有两种方式获取安装包：

#### 方式一: 从 Artifacts 下载

1. 在 Actions 运行详情页面
2. 滚动到底部的 **Artifacts** 部分
3. 下载对应平台的压缩包

#### 方式二: 从 Releases 下载

1. 回到仓库首页
2. 点击右侧的 **Releases**
3. 找到最新创建的 Release (名称格式: `应用名-v版本号`)
4. 下载对应平台的安装包

## 配置示例

### 示例 1: 打包 YouTube

```yaml
应用名称: YouTube
应用 URL: https://www.youtube.com
版本号: 1.0.0
标识符: com.myname.youtube
窗口宽度: 1400
窗口高度: 900
调试模式: false
平台: macos-arm,windows-x64
```

### 示例 2: 打包 ChatGPT (带自定义 JS)

```yaml
应用名称: ChatGPT
应用 URL: https://chat.openai.com
版本号: 1.0.0
标识符: com.myname.chatgpt
窗口宽度: 1200
窗口高度: 800
调试模式: true
平台: macos-arm,macos-intel,windows-x64,linux-x64
自定义 JS: |
  console.log('ChatGPT 客户端已启动');
  // 隐藏某些元素示例
  document.addEventListener('DOMContentLoaded', () => {
    const ads = document.querySelectorAll('.ad-banner');
    ads.forEach(ad => ad.style.display = 'none');
  });
```

### 示例 3: 打包内部网站

```yaml
应用名称: CompanyPortal
应用 URL: https://internal.company.com/portal
版本号: 2.0.0
标识符: com.company.portal
窗口宽度: 1600
窗口高度: 1000
调试模式: false
平台: windows-x64,linux-x64
```

## 安装和使用

### macOS

1. 下载 `.dmg` 文件
2. 双击打开，拖动应用到 Applications 文件夹
3. 首次运行时，如果提示"应用已损坏"，运行:
   ```bash
   sudo xattr -r -d com.apple.quarantine /Applications/应用名.app
   ```

### Windows

1. 下载 `.exe` 或 `.msi` 文件
2. 双击安装
3. 如有安全提示，选择"仍要运行"

### Linux

**Ubuntu/Debian (.deb)**
```bash
sudo dpkg -i 应用名_版本_amd64.deb
```

**Fedora/RHEL (.rpm)**
```bash
sudo rpm -i 应用名-版本.x86_64.rpm
```

## 注意事项

1. **GitHub Token**: 工作流会自动使用 GitHub 的 `GITHUB_TOKEN`，无需额外配置

2. **构建时间**:
   - 单平台: 约 10-15 分钟
   - 多平台: 约 20-40 分钟

3. **产物保留期**: Artifacts 默认保留 7 天，Releases 永久保留

4. **私密性**:
   - 如果仓库是私有的，只有你能看到构建产物
   - 如果是公开仓库，任何人都能下载

5. **自定义 JS**:
   - JS 代码会在页面加载时执行
   - 可以用来修改页面样式、隐藏广告、自动填充表单等
   - 注意遵守目标网站的使用条款

6. **调试模式**:
   - 启用后可以右键打开开发者工具
   - 生产环境建议关闭

## 高级技巧

### 批量打包多个应用

你可以多次运行工作流，每次使用不同的参数来打包不同的应用。

### 自动化打包

如果需要定期重新打包（比如每周更新一次），可以修改工作流文件，添加定时触发：

```yaml
on:
    workflow_dispatch:  # 保留手动触发
    schedule:
        - cron: '0 0 * * 0'  # 每周日午夜 UTC 时间触发
```

### 自定义构建脚本

如果需要更复杂的构建逻辑，可以在 `.github/workflows/custom-pack.yml` 中添加自定义步骤。

## 常见问题

### Q: 为什么构建失败？

A: 常见原因:
- 应用标识符格式不正确（必须是 `com.xxx.xxx` 格式）
- 选择的平台字符串有误（检查逗号分隔）
- 网络问题导致依赖下载失败（重新运行即可）

### Q: TAURI_SIGNING_PRIVATE_KEY 或 pubkey 错误是什么？

A: 这是 Tauri 应用更新器签名相关的错误。工作流已自动处理此问题：

**Token 说明**:
- **GITHUB_TOKEN**: GitHub 自动提供，用于仓库操作（无需配置）✅
- **TAURI_SIGNING_PRIVATE_KEY**: 应用签名私钥（工作流已禁用）✅

**自动修复内容**:
1. 从 `tauri.conf.json` 中删除 `updater` 配置
2. 在 `lib.rs` 中注释掉更新器插件注册
3. 构建完成后自动恢复原始文件

如果仍然遇到此错误，请确保使用最新版本的 `custom-pack.yml` 工作流文件。

**本地测试**:
```bash
# 运行测试脚本验证修改逻辑
./scripts/test-disable-updater.sh
```

### Q: 如何修改应用图标？

A: 替换项目根目录的 `app-icon.png` 文件（最小 512x512px），然后重新运行工作流。

### Q: 可以打包需要登录的网站吗？

A: 可以，但登录状态不会保存在应用中。用户需要在应用内重新登录。

### Q: 打包的应用有多大？

A: 通常在 5-15MB 之间，比 Electron 应用小很多。

## 技术支持

如遇到问题，请提交 Issue 到 GitHub 仓库。
