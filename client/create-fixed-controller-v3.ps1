# 创建修复后的ShortcutKeyController.java文件 - 版本3

# 创建临时目录
$tempDir = "h:/erpcrm/client/temp_final_fix_v3"
if (Test-Path $tempDir) {
    Remove-Item -Path $tempDir -Recurse -Force
}
New-Item -Path $tempDir -ItemType Directory

# 创建src/main/java/com/erpcrm/controller目录结构
$controllerDir = "$tempDir/src/main/java/com/erpcrm/controller"
New-Item -Path $controllerDir -ItemType Directory -Force

# 直接创建正确的ShortcutKeyController.java文件
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

# 保存文件，使用UTF-8编码但没有BOM
[System.IO.File]::WriteAllText("$controllerDir/ShortcutKeyController.java", $fixedContent, [System.Text.Encoding]::UTF8)

Write-Host "修复后的ShortcutKeyController.java已创建在：$controllerDir/ShortcutKeyController.java"

# 复制其他必要文件
Write-Host "复制其他必要文件..."
Copy-Item -Path "h:/erpcrm/server/pom.xml" -Destination "$tempDir/pom.xml" -Force
Copy-Item -Path "h:/erpcrm/server/src" -Destination "$tempDir/src" -Recurse -Force

# 替换损坏的ShortcutKeyController.java文件
Write-Host "替换损坏的ShortcutKeyController.java文件..."
Copy-Item -Path "$controllerDir/ShortcutKeyController.java" -Destination "$tempDir/src/main/java/com/erpcrm/controller/ShortcutKeyController.java" -Force

Write-Host "所有文件已准备好，现在开始编译..."

# 编译修复后的代码
& "C:\Program Files\apache-maven-3.9.9\bin\mvn.cmd" -f "$tempDir/pom.xml" compile -DskipTests

Write-Host "编译完成！"
Write-Host "临时目录：$tempDir"