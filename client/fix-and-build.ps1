# 修复并构建后端应用

# 创建临时目录
$tempDir = "h:/erpcrm/client/temp_server_fixed"
if (Test-Path $tempDir) {
    Remove-Item -Path $tempDir -Recurse -Force
}
New-Item -Path $tempDir -ItemType Directory

Write-Host "Copying server code to temporary directory..."
# 复制server目录的代码到临时目录
Copy-Item -Path "h:/erpcrm/server/*" -Destination $tempDir -Recurse

# 修复ShortcutKeyController.java
$shortcutKeyControllerPath = "$tempDir/src/main/java/com/erpcrm/controller/ShortcutKeyController.java"
if (Test-Path $shortcutKeyControllerPath) {
    Write-Host "Fixing $shortcutKeyControllerPath..."
    $content = Get-Content -Path $shortcutKeyControllerPath
    $newContent = $content -replace "com.erpcrm.server.dto", "com.erpcrm.dto" -replace "com.erpcrm.server.service", "com.erpcrm.service" -replace "com.erpcrm.server.util", "com.erpcrm.util"
    Set-Content -Path $shortcutKeyControllerPath -Value $newContent -Force
    Write-Host "Fixed $shortcutKeyControllerPath"
}

# 修复ApprovalDelegateController.java
$approvalDelegateControllerPath = "$tempDir/src/main/java/com/erpcrm/controller/ApprovalDelegateController.java"
if (Test-Path $approvalDelegateControllerPath) {
    Write-Host "Fixing $approvalDelegateControllerPath..."
    $content = Get-Content -Path $approvalDelegateControllerPath
    $newContent = $content -replace "com.erpcrm.server.dto", "com.erpcrm.dto" -replace "com.erpcrm.server.service", "com.erpcrm.service" -replace "com.erpcrm.server.util", "com.erpcrm.util"
    Set-Content -Path $approvalDelegateControllerPath -Value $newContent -Force
    Write-Host "Fixed $approvalDelegateControllerPath"
}

# 编译修复后的代码
Write-Host "Compiling fixed code..."
& "C:\Program Files\apache-maven-3.9.9\bin\mvn.cmd" -f "$tempDir/pom.xml" compile -DskipTests

Write-Host "Fix and build completed!"
