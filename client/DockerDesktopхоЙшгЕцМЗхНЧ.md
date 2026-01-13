# Docker Desktop 官方版安装指南

## 官方下载地址

Docker Desktop 官方下载页面：
[https://www.docker.com/products/docker-desktop/](https://www.docker.com/products/docker-desktop/)

## 下载步骤

1. 打开浏览器，访问上述官方下载页面
2. 在页面中找到 "Download Docker Desktop" 按钮
3. 点击该按钮，系统会自动检测您的操作系统并开始下载适合的版本
4. 等待下载完成（文件大小约571MB）

## 安装步骤

1. 双击下载好的安装程序（通常命名为 `Docker Desktop Installer.exe`）
2. 在安装向导中，勾选以下两个选项：
   - Use WSL 2 instead of Hyper-V (推荐)
   - Add shortcut to desktop
3. 点击 "OK" 开始安装
4. 等待安装完成，然后点击 "Close and restart" 重启计算机

## 验证安装

1. 计算机重启后，启动 Docker Desktop
2. 在系统托盘找到 Docker 图标，右键点击查看状态
3. 打开 PowerShell 或命令提示符，运行以下命令验证安装：
   ```powershell
   docker --version
   docker-compose --version
   ```
4. 如果能看到版本信息，说明安装成功

## 系统要求

在安装 Docker Desktop 之前，请确保您的系统满足以下要求：

### Windows 10/11
- Windows 10 64位：专业版、企业版或教育版 21H2（内部版本 19044）或更高版本
- Windows 11 64位：专业版、企业版或教育版 22H2（内部版本 22621）或更高版本
- 64位处理器，第二级地址转换 (SLAT)
- 4GB 系统内存
- 在 BIOS/UEFI 中启用硬件虚拟化
- WSL 2 功能已启用

### WSL 2 要求
- WSL 版本 2.1.5 或更高版本
- 在 Windows 系统中启用 WSL 2 功能

## 启用 WSL 2

如果您的系统尚未启用 WSL 2，可以按照以下步骤启用：

1. 以管理员身份打开 PowerShell
2. 运行以下命令启用 WSL 功能：
   ```powershell
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
   ```
3. 运行以下命令启用虚拟机平台：
   ```powershell
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
   ```
4. 重启计算机
5. 下载并安装 WSL 2 Linux 内核更新包：
   [https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi)
6. 设置 WSL 2 为默认版本：
   ```powershell
   wsl --set-default-version 2
   ```

## 常见问题解决

### 安装过程中提示缺少依赖
- 确保已启用 WSL 2 和虚拟机平台功能
- 确保已安装最新的 WSL 2 Linux 内核更新包

### 安装后无法启动
- 检查 BIOS/UEFI 中是否启用了硬件虚拟化
- 检查系统是否满足最低要求
- 尝试以管理员身份运行 Docker Desktop

### 运行 docker 命令时提示权限不足
- 确保您的用户账号已添加到 docker-users 组
- 或者以管理员身份运行命令提示符/PowerShell

## 后续步骤

安装完成后，您可以按照 `h:\erpcrm\client\后端部署指南.md` 中的步骤部署 ERP+CRM 系统后端服务。

**注意**：请确保使用的是官方版 Docker Desktop，不要使用简化版或第三方修改版，以避免出现兼容性问题。
