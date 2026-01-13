# 修复并部署ERP+CRM后端服务

# 创建临时目录
$tempDir = "h:/erpcrm/client/temp_server_deploy"
if (Test-Path $tempDir) {
    Remove-Item -Path $tempDir -Recurse -Force
}
New-Item -Path $tempDir -ItemType Directory

Write-Host "Step 1: 复制server代码到临时目录..."
# 复制server目录的代码到临时目录
Copy-Item -Path "h:/erpcrm/server/*" -Destination $tempDir -Recurse

Write-Host "Step 2: 修复ShortcutKeyController.java..."
# 修复ShortcutKeyController.java
$shortcutKeyControllerPath = "$tempDir/src/main/java/com/erpcrm/controller/ShortcutKeyController.java"
if (Test-Path $shortcutKeyControllerPath) {
    $content = Get-Content -Path $shortcutKeyControllerPath
    # 查看文件内容，了解当前的import语句
    Write-Host "当前ShortcutKeyController.java内容："
    $content | Write-Host
    
    # 修复dto和service包，但保留util包为server.util
    $newContent = $content -replace "com.erpcrm.server.dto", "com.erpcrm.dto" -replace "com.erpcrm.server.service", "com.erpcrm.service"
    Set-Content -Path $shortcutKeyControllerPath -Value $newContent -Force
    Write-Host "修复后的ShortcutKeyController.java："
    $newContent | Write-Host
}

Write-Host "Step 3: 编译修复后的代码..."
# 编译修复后的代码
& "C:\Program Files\apache-maven-3.9.9\bin\mvn.cmd" -f "$tempDir/pom.xml" compile -DskipTests

Write-Host "Step 4: 创建Windows兼容的Dockerfile..."
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
Set-Content -Path $dockerfilePath -Value $dockerfileContent -Force
Write-Host "Dockerfile创建完成"

Write-Host "Step 5: 构建Docker镜像..."
# 构建Docker镜像
& "C:\Program Files\Docker\Docker\resources\bin\docker.exe" build -t erpcrm-backend:latest $tempDir

Write-Host "Step 6: 部署后端服务..."
# 部署后端服务
& "C:\Program Files\Docker\Docker\resources\bin\docker-compose.exe" -f "h:/erpcrm/client/docker-compose-windows-final.yml" up -d

Write-Host "修复并部署完成！"
