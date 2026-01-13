#!/usr/bin/env pwsh

# 定义固定端口
$FIXED_PORT = 8080

# 检查端口是否被占用
function Check-Port {
    param ( [int]$Port )
    $processes = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    return $processes -ne $null
}

# 尝试使用固定端口启动
if (Check-Port $FIXED_PORT) {
    Write-Host "端口 $FIXED_PORT 已被占用，尝试终止占用该端口的进程..."
    # 终止占用端口的进程
    $processes = Get-NetTCPConnection -LocalPort $FIXED_PORT -ErrorAction SilentlyContinue
    if ($processes) {
        foreach ($process in $processes) {
            try {
                Stop-Process -Id $process.OwningProcess -Force -ErrorAction SilentlyContinue
                Write-Host "已终止进程 $($process.OwningProcess)"
            } catch {
                Write-Host "无法终止进程 $($process.OwningProcess): $_"
            }
        }
        Start-Sleep -Seconds 2
    }
}

# 再次检查端口是否可用
if (Check-Port $FIXED_PORT) {
    Write-Host "端口 $FIXED_PORT 仍被占用，无法启动服务"
    exit 1
}

Write-Host "使用固定端口 $FIXED_PORT 启动Flutter Web项目..."
flutter run -d chrome --web-port=$FIXED_PORT
