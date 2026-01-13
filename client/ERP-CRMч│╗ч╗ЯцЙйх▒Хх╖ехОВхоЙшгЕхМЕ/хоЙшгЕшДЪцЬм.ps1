# ERP+CRM系统扩展工厂安装脚本

Write-Host "========================================"
Write-Host "ERP+CRM系统扩展工厂 安装程序"
Write-Host "========================================"
Write-Host ""

# 1. 设置默认安装路径
$defaultInstallPath = "C:\Program Files\ERP-CRM"
$installPath = Read-Host "请输入安装路径 [默认: $defaultInstallPath]"

if ([string]::IsNullOrEmpty($installPath)) {
    $installPath = $defaultInstallPath
}

# 2. 创建安装目录
Write-Host ""
Write-Host "正在创建安装目录: $installPath"
try {
    New-Item -ItemType Directory -Path $installPath -Force | Out-Null
    Write-Host "✓ 安装目录创建成功"
} catch {
    Write-Host "✗ 安装目录创建失败: $_"
    Pause
    exit 1
}

# 3. 复制应用文件
Write-Host ""
Write-Host "正在复制应用文件..."
try {
    # 获取当前脚本所在目录
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $appSource = Join-Path $scriptDir "Release"
    
    # 复制所有文件和子目录
    Copy-Item -Path "$appSource\*" -Destination $installPath -Recurse -Force
    Write-Host "✓ 应用文件复制成功"
} catch {
    Write-Host "✗ 应用文件复制失败: $_"
    Pause
    exit 1
}

# 4. 创建桌面快捷方式
Write-Host ""
Write-Host "正在创建桌面快捷方式..."
try {
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\ERP+CRM系统扩展工厂.lnk")
    $Shortcut.TargetPath = "$installPath\client.exe"
    $Shortcut.WorkingDirectory = $installPath
    $Shortcut.Save()
    Write-Host "✓ 桌面快捷方式创建成功"
} catch {
    Write-Host "✗ 桌面快捷方式创建失败: $_"
    # 继续执行，不中断安装
}

# 5. 创建开始菜单快捷方式
Write-Host ""
Write-Host "正在创建开始菜单快捷方式..."
try {
    $startMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\ERP-CRM"
    New-Item -ItemType Directory -Path $startMenuPath -Force | Out-Null
    
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$startMenuPath\系统扩展工厂.lnk")
    $Shortcut.TargetPath = "$installPath\client.exe"
    $Shortcut.WorkingDirectory = $installPath
    $Shortcut.Save()
    Write-Host "✓ 开始菜单快捷方式创建成功"
} catch {
    Write-Host "✗ 开始菜单快捷方式创建失败: $_"
    # 继续执行，不中断安装
}

# 6. 显示安装完成信息
Write-Host ""
Write-Host "========================================"
Write-Host "🎉 安装完成！"
Write-Host "========================================"
Write-Host "应用安装路径: $installPath"
Write-Host "桌面已创建快捷方式"
Write-Host "开始菜单已创建快捷方式"
Write-Host ""
Write-Host "使用说明:"
Write-Host "1. 双击桌面快捷方式启动应用"
Write-Host "2. 或从开始菜单 -> ERP-CRM -> 系统扩展工厂启动"
Write-Host "3. 默认后端地址: http://localhost:8080"
Write-Host ""
Write-Host "========================================"

# 7. 询问是否立即运行
$runNow = Read-Host "是否立即运行应用? (Y/N) [默认: N]"
if ($runNow -eq "Y" -or $runNow -eq "y") {
    Write-Host "正在启动应用..."
    Start-Process -FilePath "$installPath\client.exe"
}

Write-Host ""
Write-Host "按任意键退出..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")