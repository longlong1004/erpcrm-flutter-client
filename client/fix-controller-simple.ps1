# 简化版修复控制器脚本

# 设置PowerShell编码为UTF-8
$OutputEncoding = [System.Console]::OutputEncoding = [System.Console]::InputEncoding = [System.Text.UTF8Encoding]::new()

# 创建临时目录
$tempDir = "h:/erpcrm/client/temp_simple_fix"
if (Test-Path $tempDir) {
    Remove-Item -Path $tempDir -Recurse -Force
}
New-Item -Path $tempDir -ItemType Directory

Write-Host "修复ShortcutKeyController.java文件..."

# 直接创建正确的ShortcutKeyController.java文件内容
$fixedContent = @'
package com.erpcrm.controller;

import com.erpcrm.dto.ShortcutKeyDTO;
import com.erpcrm.service.ShortcutKeyService;
import com.erpcrm.server.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/shortcut-keys")
@CrossOrigin(origins = "*")
public class ShortcutKeyController {
    
    @Autowired
    private ShortcutKeyService shortcutKeyService;
    
    @GetMapping
    public ResponseEntity<List<ShortcutKeyDTO>> getShortcutKeys(
            @RequestHeader("Authorization") String token) {
        Long userId = JwtUtil.getUserIdFromToken(token);
        List<ShortcutKeyDTO> keys = shortcutKeyService.getUserShortcutKeys(userId);
        return ResponseEntity.ok(keys);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<ShortcutKeyDTO> updateShortcutKey(
            @PathVariable Long id,
            @RequestBody ShortcutKeyDTO dto,
            @RequestHeader("Authorization") String token) {
        Long userId = JwtUtil.getUserIdFromToken(token);
        ShortcutKeyDTO updated = shortcutKeyService.updateShortcutKey(userId, id, dto);
        return ResponseEntity.ok(updated);
    }
    
    @PostMapping("/reset")
    public ResponseEntity<Void> resetToDefault(
            @RequestHeader("Authorization") String token) {
        Long userId = JwtUtil.getUserIdFromToken(token);
        shortcutKeyService.resetToDefault(userId);
        return ResponseEntity.ok().build();
    }
    
    @PostMapping("/reset/{functionId}")
    public ResponseEntity<Void> resetSingleShortcutToDefault(
            @PathVariable String functionId,
            @RequestHeader("Authorization") String token) {
        Long userId = JwtUtil.getUserIdFromToken(token);
        shortcutKeyService.resetSingleShortcutToDefault(userId, functionId);
        return ResponseEntity.ok().build();
    }
    
    @PostMapping("/usage/{functionId}")
    public ResponseEntity<Void> recordUsage(
            @PathVariable String functionId,
            @RequestHeader("Authorization") String token) {
        Long userId = JwtUtil.getUserIdFromToken(token);
        shortcutKeyService.incrementUsageCount(userId, functionId);
        return ResponseEntity.ok().build();
    }
}
'@

# 保存修复后的文件，确保没有BOM字符
$fixedFilePath = "$tempDir/ShortcutKeyController.java.fixed"
Set-Content -Path $fixedFilePath -Value $fixedContent -Force -Encoding ASCII

Write-Host "修复后的文件已保存到：$fixedFilePath"
Write-Host "请手动将此文件复制到 server/src/main/java/com/erpcrm/controller/ 目录下"
Write-Host "然后运行：mvn clean compile -DskipTests 检查编译结果"
