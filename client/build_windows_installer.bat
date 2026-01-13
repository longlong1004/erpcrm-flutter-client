@echo off
REM ERP+CRM系统客户端安装脚本
REM 创建于 2025-12-24

echo ==========================================
echo ERP+CRM系统客户端安装脚本
echo ==========================================
echo.

REM 检查是否以管理员权限运行
net session >nul 2>&1
if %errorLevel% NEQ 0 (
echo 请以管理员权限运行此安装脚本！
echo.
pause
exit /b 1
)

REM 设置默认安装路径
set "INSTALL_DIR=%ProgramFiles%\ERPCRM Client"
set "APP_NAME=国铁商城ERP-CRM"
set "EXE_NAME=client.exe"
set "BACKEND_IP=127.0.0.1"
set "BACKEND_PORT=8080"

REM 获取用户输入
echo 默认安装路径: %INSTALL_DIR%
echo 按回车使用默认路径，或输入新路径:
set /p "USER_INSTALL_DIR="
if not "%USER_INSTALL_DIR%"=="" set "INSTALL_DIR=%USER_INSTALL_DIR%"

echo.
echo 默认后端服务器IP: %BACKEND_IP%
echo 默认后端服务器端口: %BACKEND_PORT%
echo 按回车使用默认配置，或输入新的IP和端口:
set /p "USER_BACKEND="
if not "%USER_BACKEND%"=="" (
    for /f "tokens=1,2 delims=:" %%a in ("%USER_BACKEND%") do (
        set "BACKEND_IP=%%a"
        set "BACKEND_PORT=%%b"
    )
)

echo.
echo 正在安装...

REM 创建安装目录
mkdir "%INSTALL_DIR%" 2>nul
if %errorLevel% NEQ 0 (
    echo 创建安装目录失败！
    pause
exit /b 1
)

REM 复制应用文件
echo 正在复制应用文件...
copy /y "%~dp0\build\windows\x64\runner\Release\*" "%INSTALL_DIR%" >nul
if %errorLevel% NEQ 0 (
    echo 复制应用文件失败！
    pause
exit /b 1
)

REM 创建桌面快捷方式
echo 正在创建桌面快捷方式...
set "DESKTOP=%USERPROFILE%\Desktop"
set "SHORTCUT=%DESKTOP%\%APP_NAME%.lnk"
set "WSH_SCRIPT=%TEMP%\CreateShortcut.vbs"

REM 使用VBScript创建快捷方式
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%WSH_SCRIPT%"
echo sLinkFile = "%SHORTCUT%" >> "%WSH_SCRIPT%"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%WSH_SCRIPT%"
echo oLink.TargetPath = "%INSTALL_DIR%\%EXE_NAME%" >> "%WSH_SCRIPT%"
echo oLink.WorkingDirectory = "%INSTALL_DIR%" >> "%WSH_SCRIPT%"
echo oLink.Description = "%APP_NAME%客户端" >> "%WSH_SCRIPT%"
echo oLink.Save >> "%WSH_SCRIPT%"

cscript //nologo "%WSH_SCRIPT%"
del /f /q "%WSH_SCRIPT%" 2>nul

REM 创建开始菜单快捷方式
echo 正在创建开始菜单快捷方式...
set "START_MENU=%APPDATA%\Microsoft\Windows\Start Menu\Programs\%APP_NAME%"
mkdir "%START_MENU%" 2>nul
set "START_SHORTCUT=%START_MENU%\%APP_NAME%.lnk"

REM 使用VBScript创建开始菜单快捷方式
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%WSH_SCRIPT%"
echo sLinkFile = "%START_SHORTCUT%" >> "%WSH_SCRIPT%"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%WSH_SCRIPT%"
echo oLink.TargetPath = "%INSTALL_DIR%\%EXE_NAME%" >> "%WSH_SCRIPT%"
echo oLink.WorkingDirectory = "%INSTALL_DIR%" >> "%WSH_SCRIPT%"
echo oLink.Description = "%APP_NAME%客户端" >> "%WSH_SCRIPT%"
echo oLink.Save >> "%WSH_SCRIPT%"

cscript //nologo "%WSH_SCRIPT%"
del /f /q "%WSH_SCRIPT%" 2>nul

REM 创建卸载脚本
echo 正在创建卸载脚本...
set "UNINSTALL_SCRIPT=%INSTALL_DIR%\uninstall.bat"
echo @echo off > "%UNINSTALL_SCRIPT%"
echo echo ========================================== >> "%UNINSTALL_SCRIPT%"
echo echo ERP+CRM系统客户端卸载脚本 >> "%UNINSTALL_SCRIPT%"
echo echo ========================================== >> "%UNINSTALL_SCRIPT%"
echo echo. >> "%UNINSTALL_SCRIPT%"
echo echo 确定要卸载 %APP_NAME% 吗？ >> "%UNINSTALL_SCRIPT%"
echo echo. >> "%UNINSTALL_SCRIPT%"
echo echo 按Y键卸载，按其他键取消 >> "%UNINSTALL_SCRIPT%"
echo set /p "CONFIRM=" >> "%UNINSTALL_SCRIPT%"
echo if /i not "!CONFIRM!"=="Y" exit /b 0 >> "%UNINSTALL_SCRIPT%"
echo echo. >> "%UNINSTALL_SCRIPT%"
echo echo 正在卸载... >> "%UNINSTALL_SCRIPT%"
echo echo 删除桌面快捷方式... >> "%UNINSTALL_SCRIPT%"
echo del /f /q "%DESKTOP%\%APP_NAME%.lnk" 2^>nul >> "%UNINSTALL_SCRIPT%"
echo echo 删除开始菜单快捷方式... >> "%UNINSTALL_SCRIPT%"
echo rmdir /s /q "%START_MENU%" 2^>nul >> "%UNINSTALL_SCRIPT%"
echo echo 删除应用文件... >> "%UNINSTALL_SCRIPT%"
echo rmdir /s /q "%INSTALL_DIR%" 2^>nul >> "%UNINSTALL_SCRIPT%"
echo echo 卸载完成！ >> "%UNINSTALL_SCRIPT%"
echo pause >> "%UNINSTALL_SCRIPT%"
echo exit /b 0 >> "%UNINSTALL_SCRIPT%"

REM 设置脚本为可执行
icacls "%UNINSTALL_SCRIPT%" /grant:r "Users:F" >nul

REM 创建开始菜单卸载快捷方式
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%WSH_SCRIPT%"
echo sLinkFile = "%START_MENU%\卸载 %APP_NAME%.lnk" >> "%WSH_SCRIPT%"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%WSH_SCRIPT%"
echo oLink.TargetPath = "%UNINSTALL_SCRIPT%" >> "%WSH_SCRIPT%"
echo oLink.WorkingDirectory = "%INSTALL_DIR%" >> "%WSH_SCRIPT%"
echo oLink.Description = "卸载 %APP_NAME%" >> "%WSH_SCRIPT%"
echo oLink.Save >> "%WSH_SCRIPT%"

cscript //nologo "%WSH_SCRIPT%"
del /f /q "%WSH_SCRIPT%" 2>nul

echo.
echo 安装完成！
echo 安装路径: %INSTALL_DIR%
echo 后端服务器: %BACKEND_IP%:%BACKEND_PORT%
echo 桌面快捷方式: %SHORTCUT%
echo.
echo 按任意键退出...
pause >nul
