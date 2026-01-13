# 修复并部署ERP+CRM后端服务 - 版本3

# 设置PowerShell编码为UTF-8
$OutputEncoding = [System.Console]::OutputEncoding = [System.Console]::InputEncoding = [System.Text.UTF8Encoding]::new()

# 创建临时目录
$tempDir = "h:/erpcrm/client/temp_server_deploy_v3"
if (Test-Path $tempDir) {
    Remove-Item -Path $tempDir -Recurse -Force
}
New-Item -Path $tempDir -ItemType Directory

Write-Host "Step 1: 复制server代码到临时目录..." -ForegroundColor Cyan
# 复制server目录的代码到临时目录
Copy-Item -Path "h:/erpcrm/server/*" -Destination $tempDir -Recurse

Write-Host "Step 2: 修复ShortcutKeyController.java..." -ForegroundColor Cyan
# 修复ShortcutKeyController.java
$shortcutKeyControllerPath = "$tempDir/src/main/java/com/erpcrm/controller/ShortcutKeyController.java"
if (Test-Path $shortcutKeyControllerPath) {
    Write-Host "正在读取ShortcutKeyController.java文件..." -ForegroundColor Yellow
    $content = Get-Content -Path $shortcutKeyControllerPath -Raw
    
    Write-Host "修复前的import语句：" -ForegroundColor Yellow
    $content | Select-String -Pattern "import" | Write-Host
    
    # 修复import语句，将com.erpcrm.server.替换为com.erpcrm.
    $newContent = $content -replace "com\.erpcrm\.server\.dto", "com.erpcrm.dto" -replace "com\.erpcrm\.server\.service", "com.erpcrm.service"
    
    # 检查util包的实际位置
    $utilPath = "$tempDir/src/main/java/com/erpcrm/server/util"
    if (Test-Path $utilPath -PathType Container) {
        Write-Host "util包存在于com.erpcrm.server.util路径下，不修改util包的import语句" -ForegroundColor Yellow
    } else {
        $newContent = $newContent -replace "com\.erpcrm\.server\.util", "com.erpcrm.util"
        Write-Host "util包不存在于com.erpcrm.server.util路径下，修改util包的import语句" -ForegroundColor Yellow
    }
    
    Write-Host "修复后的import语句：" -ForegroundColor Green
    $newContent | Select-String -Pattern "import" | Write-Host
    
    # 保存修复后的文件
    Set-Content -Path $shortcutKeyControllerPath -Value $newContent -Force -Encoding UTF8
    Write-Host "ShortcutKeyController.java文件修复完成" -ForegroundColor Green
}

Write-Host "Step 3: 编译修复后的代码..." -ForegroundColor Cyan
# 编译修复后的代码
& "C:\Program Files\apache-maven-3.9.9\bin\mvn.cmd" -f "$tempDir/pom.xml" compile -DskipTests

Write-Host "Step 4: 检查Docker Desktop状态..." -ForegroundColor Cyan
# 检查Docker Desktop状态
& "C:\Program Files\Docker\Docker\resources\bin\docker.exe" info

Write-Host "Step 5: 创建Windows兼容的Dockerfile..." -ForegroundColor Cyan
# 创建Windows兼容的Dockerfile
$dockerfileContent = @'
# 第一阶段：构建阶段
FROM maven:3.9.4-eclipse-temurin-17 AS builder

WORKDIR /app

# 复制pom.xml和源代码
COPY pom.xml .
COPY src ./src

# 构建项目
RUN mvn clean package -DskipTests

# 第二阶段：运行阶段
FROM openjdk:17-alpine

WORKDIR /app

# 从构建阶段复制jar文件
COPY --from=builder /app/target/erpcrm-server-1.0.0-SNAPSHOT.jar app.jar

# 暴露端口
EXPOSE 8080

# 启动应用
ENTRYPOINT ["java", "-jar", "app.jar"]
'@

$dockerfilePath = "$tempDir/Dockerfile"
Set-Content -Path $dockerfilePath -Value $dockerfileContent -Force -Encoding UTF8
Write-Host "Dockerfile创建完成" -ForegroundColor Green

Write-Host "修复并部署脚本执行完成！" -ForegroundColor Cyan
Write-Host "下一步建议：" -ForegroundColor Yellow
Write-Host "1. 检查Docker Desktop是否正常运行" -ForegroundColor Yellow
Write-Host "2. 确保Docker Desktop处于Windows容器模式" -ForegroundColor Yellow
Write-Host "3. 手动构建Docker镜像：docker build -t erpcrm-backend:latest $tempDir" -ForegroundColor Yellow
Write-Host "4. 手动部署服务：docker-compose -f docker-compose-windows-minimal.yml up -d" -ForegroundColor Yellow
