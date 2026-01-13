# 修复ERP+CRM系统后端服务编译错误的脚本

Write-Host "开始修复编译错误..."

# 修复ShortcutKeyController.java文件
Write-Host "修复ShortcutKeyController.java文件..."
$shortcutKeyControllerPath = "h:\erpcrm\server\src\main\java\com\erpcrm\controller\ShortcutKeyController.java"
$shortcutKeyControllerContent = Get-Content -Path $shortcutKeyControllerPath -Raw
$fixedShortcutKeyControllerContent = $shortcutKeyControllerContent -replace "com.erpcrm.dto", "com.erpcrm.server.dto" `
    -replace "com.erpcrm.service", "com.erpcrm.server.service" `
    -replace "com.erpcrm.util.auth.JwtUtil", "com.erpcrm.server.util.JwtUtil"
Set-Content -Path $shortcutKeyControllerPath -Value $fixedShortcutKeyControllerContent -Encoding UTF8

# 修复ApprovalDelegateController.java文件
Write-Host "修复ApprovalDelegateController.java文件..."
$approvalDelegateControllerPath = "h:\erpcrm\server\src\main\java\com\erpcrm\controller\ApprovalDelegateController.java"
$approvalDelegateControllerContent = Get-Content -Path $approvalDelegateControllerPath -Raw

# 替换包路径
$fixedApprovalDelegateControllerContent = $approvalDelegateControllerContent -replace "com.erpcrm.common.Result", "com.erpcrm.server.dto.ResponseDTO"
$fixedApprovalDelegateControllerContent = $fixedApprovalDelegateControllerContent -replace "com.erpcrm.model", "com.erpcrm.server.model"
$fixedApprovalDelegateControllerContent = $fixedApprovalDelegateControllerContent -replace "com.erpcrm.service", "com.erpcrm.server.service"

# 替换Result为ResponseDTO
$fixedApprovalDelegateControllerContent = $fixedApprovalDelegateControllerContent -replace "Result.success", "ResponseDTO.success"
$fixedApprovalDelegateControllerContent = $fixedApprovalDelegateControllerContent -replace "Result.error", "ResponseDTO.error"

# 替换返回类型
$fixedApprovalDelegateControllerContent = $fixedApprovalDelegateControllerContent -replace "public Result\<\?\>", "public ResponseDTO\<\?\>"

Set-Content -Path $approvalDelegateControllerPath -Value $fixedApprovalDelegateControllerContent -Encoding UTF8

Write-Host "编译错误修复完成！"
Write-Host "现在您可以运行以下命令来构建后端服务："
Write-Host "cd h:\erpcrm\server && mvn clean package -DskipTests"
