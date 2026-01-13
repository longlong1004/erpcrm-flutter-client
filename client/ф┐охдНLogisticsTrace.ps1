# 修复LogisticsTrace.java文件中的index()方法问题
$logisticsTracePath = "h:\erpcrm\server\src\main\java\com\erpcrm\server\model\logistics\LogisticsTrace.java"

# 检查文件是否存在
if (Test-Path $logisticsTracePath) {
    Write-Host "正在修复 $logisticsTracePath 文件..."
    
    # 读取文件内容
    $content = Get-Content -Path $logisticsTracePath -Raw
    
    # 替换index()方法
    $newContent = $content -replace '@Column\(name = "logistics_id", nullable = false, index = true\)', '@Column(name = "logistics_id", nullable = false)'
    
    # 保存修改后的文件
    Set-Content -Path $logisticsTracePath -Value $newContent
    
    Write-Host "修复完成！"
    Write-Host "已将 @Column(name = \"logistics_id\", nullable = false, index = true)"
    Write-Host "修改为：@Column(name = \"logistics_id\", nullable = false)"
} else {
    Write-Host "错误：找不到文件 $logisticsTracePath"
}
