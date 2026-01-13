# 在client目录下构建带修复的Docker镜像

# 创建临时目录
$tempDir = "h:/erpcrm/client/temp_server"
if (Test-Path $tempDir) {
    Remove-Item -Path $tempDir -Recurse -Force
}
New-Item -Path $tempDir -ItemType Directory

Write-Host "Copying server code to temporary directory..."
# 复制server目录的代码到临时目录
Copy-Item -Path "h:/erpcrm/server/*" -Destination $tempDir -Recurse

# 修复控制器中的import语句
$shortcutKeyControllerPath = "$tempDir/src/main/java/com/erpcrm/controller/ShortcutKeyController.java"
if (Test-Path $shortcutKeyControllerPath) {
    Write-Host "Fixing $shortcutKeyControllerPath..."
    $content = Get-Content -Path $shortcutKeyControllerPath
    $newContent = $content -replace "com.erpcrm.server.dto", "com.erpcrm.dto" -replace "com.erpcrm.server.service", "com.erpcrm.service" -replace "com.erpcrm.server.util", "com.erpcrm.util"
    Set-Content -Path $shortcutKeyControllerPath -Value $newContent -Force
    Write-Host "Fixed $shortcutKeyControllerPath"
}

$approvalDelegateControllerPath = "$tempDir/src/main/java/com/erpcrm/controller/ApprovalDelegateController.java"
if (Test-Path $approvalDelegateControllerPath) {
    Write-Host "Fixing $approvalDelegateControllerPath..."
    $content = Get-Content -Path $approvalDelegateControllerPath
    $newContent = $content -replace "com.erpcrm.server.dto", "com.erpcrm.dto" -replace "com.erpcrm.server.service", "com.erpcrm.service" -replace "com.erpcrm.server.util", "com.erpcrm.util"
    Set-Content -Path $approvalDelegateControllerPath -Value $newContent -Force
    Write-Host "Fixed $approvalDelegateControllerPath"
}

# 创建Dockerfile
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

$dockerfilePath = "$tempDir/Dockerfile.fixed"
Set-Content -Path $dockerfilePath -Value $dockerfileContent

Write-Host "Building Docker image..."
# 构建Docker镜像
& "C:\Program Files\Docker\Docker\resources\bin\docker.exe" build -t erpcrm-backend:fixed -f $dockerfilePath $tempDir

# 启动Docker容器
Write-Host "Starting Docker container..."
& "C:\Program Files\Docker\Docker\resources\bin\docker.exe" run -d --name erpcrm_backend -p 8082:8080 erpcrm-backend:fixed

Write-Host "Build and run completed!"
