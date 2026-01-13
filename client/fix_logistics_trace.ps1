# Fix LogisticsTrace.java file - remove index() method from @Column annotation
$logisticsTracePath = "h:\erpcrm\server\src\main\java\com\erpcrm\server\model\logistics\LogisticsTrace.java"

# Check if file exists
if (Test-Path $logisticsTracePath) {
    Write-Host "Fixing $logisticsTracePath..."
    
    # Read file content
    $content = Get-Content -Path $logisticsTracePath -Raw
    
    # Replace the problematic @Column annotation
    $newContent = $content -replace '@Column\(name = "logistics_id", nullable = false, index = true\)', '@Column(name = "logistics_id", nullable = false)'
    
    # Save the fixed file
    Set-Content -Path $logisticsTracePath -Value $newContent
    
    Write-Host "Fix completed!"
    Write-Host "Replaced: @Column(name = \"logistics_id\", nullable = false, index = true)"
    Write-Host "With: @Column(name = \"logistics_id\", nullable = false)"
} else {
    Write-Host "Error: File not found at $logisticsTracePath"
}
