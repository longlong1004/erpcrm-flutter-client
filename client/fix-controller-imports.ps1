# 修复控制器中的import语句问题

# 修复ShortcutKeyController.java
$shortcutKeyControllerPath = "h:/erpcrm/server/src/main/java/com/erpcrm/controller/ShortcutKeyController.java"
if (Test-Path $shortcutKeyControllerPath) {
    Write-Host "Fixing $shortcutKeyControllerPath..."
    $content = Get-Content -Path $shortcutKeyControllerPath
    $newContent = $content -replace "com.erpcrm.server.dto", "com.erpcrm.dto" -replace "com.erpcrm.server.service", "com.erpcrm.service" -replace "com.erpcrm.server.util", "com.erpcrm.util"
    Set-Content -Path $shortcutKeyControllerPath -Value $newContent -Force
    Write-Host "Fixed $shortcutKeyControllerPath"
}

# 修复ApprovalDelegateController.java
$approvalDelegateControllerPath = "h:/erpcrm/server/src/main/java/com/erpcrm/controller/ApprovalDelegateController.java"
if (Test-Path $approvalDelegateControllerPath) {
    Write-Host "Fixing $approvalDelegateControllerPath..."
    $content = Get-Content -Path $approvalDelegateControllerPath
    $newContent = $content -replace "com.erpcrm.server.dto", "com.erpcrm.dto" -replace "com.erpcrm.server.service", "com.erpcrm.service" -replace "com.erpcrm.server.util", "com.erpcrm.util"
    Set-Content -Path $approvalDelegateControllerPath -Value $newContent -Force
    Write-Host "Fixed $approvalDelegateControllerPath"
}

Write-Host "All controller imports fixed!"
