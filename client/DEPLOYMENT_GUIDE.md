# ERP+CRM后端服务部署指南

## 当前状态

✅ **已完成工作**

1. **Docker Desktop问题解决**
   - 成功修复Docker Desktop 500 Internal Server Error
   - 确保Docker Desktop在Windows容器模式下正常工作
   - 网络和端口映射配置正确

2. **容器部署成功**
   - 已部署基础容器服务，使用官方Windows Nano Server镜像
   - 容器运行状态：`Up`
   - 端口映射：`0.0.0.0:8082->8080/tcp`
   - 网络配置：使用`erpcrm_network`网络

3. **配置文件创建**
   - `docker-compose-windows-minimal.yml`：极简Windows容器配置
   - `docker-compose-windows-final.yml`：完整Windows容器配置
   - `fix-and-build-v2.ps1`：代码修复脚本
   - 其他辅助配置文件

## 剩余问题

❌ **需要修复的问题**

1. **后端代码编译错误**
   - ShortcutKeyController.java中的JwtUtil方法调用问题
   - ShortcutKeyService.java中的构造器参数不匹配问题
   - ApprovalDelegateService.java中的LocalDateTime方法调用问题
   - SystemParameterController.java中的类型转换问题

2. **Docker镜像创建**
   - 需要创建Windows兼容的Dockerfile
   - 需要构建后端应用镜像

3. **完整服务部署**
   - 配置MySQL/PostgreSQL数据库
   - 配置Redis/Memurai缓存
   - 部署完整的后端服务

## 部署步骤

### 步骤1：修复后端代码编译错误

1. **修复ShortcutKeyController.java**
   ```java
   // 检查JwtUtil类的实际方法名
   // 当前错误：getUserIdFromToken方法不存在
   // 解决方案：查看JwtUtil.java，使用正确的方法名
   ```

2. **修复ShortcutKeyService.java**
   ```java
   // 检查ShortcutKey类的构造器
   // 当前错误：构造器参数不匹配
   // 解决方案：使用@Builder或无参构造器+setter方法
   ```

3. **修复ApprovalDelegateService.java**
   ```java
   // 检查LocalDateTime.until方法的正确用法
   // 当前错误：参数数量不匹配
   // 正确用法：localDateTime.until(otherDateTime, ChronoUnit.DAYS)
   ```

4. **修复SystemParameterController.java**
   ```java
   // 修复Optional类型转换
   // 当前错误：直接将Optional转换为DTO
   // 正确用法：使用orElseThrow()或orElse(null)
   ```

### 步骤2：创建Windows兼容的Dockerfile

```dockerfile
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
```

### 步骤3：部署完整后端服务

1. **构建Docker镜像**
   ```bash
   docker build -t erpcrm-backend:latest .
   ```

2. **更新docker-compose.yml**
   ```yaml
   services:
     backend:
       image: erpcrm-backend:latest
       # 其他配置不变
   ```

3. **启动完整服务**
   ```bash
   docker-compose -f docker-compose-windows-final.yml up -d
   ```

### 步骤4：验证部署

1. **检查容器状态**
   ```bash
   docker ps
   ```

2. **查看日志**
   ```bash
   docker logs erpcrm_backend
   ```

3. **测试API**
   ```bash
   # 使用curl或Postman测试API
   curl http://localhost:8082/api/health
   ```

## 最佳实践

### 1. **代码质量**

- 使用`mvn clean compile -Xlint:unchecked`检查详细编译错误
- 修复所有编译警告
- 使用SonarQube进行代码质量检查

### 2. **Docker最佳实践**

- 使用多阶段构建减小镜像体积
- 使用`.dockerignore`文件排除不必要的文件
- 合理配置资源限制（CPU、内存）
- 使用健康检查确保服务正常运行

### 3. **部署策略**

- 使用CI/CD流水线自动化构建和部署
- 实施蓝绿部署或滚动更新
- 配置监控和告警
- 定期备份数据

### 4. **Windows容器注意事项**

- 使用官方Windows Server Core或Nano Server镜像
- 注意Windows版本兼容性（使用与主机相同的Windows版本）
- 避免使用Linux-only特性
- 合理配置容器隔离级别

## 故障排除

### 常见问题

1. **容器无法启动**
   - 检查日志：`docker logs <container_name>`
   - 检查端口冲突：`netstat -ano | findstr <port>`
   - 检查镜像完整性：`docker image inspect <image_name>`

2. **编译错误**
   - 查看详细错误信息：`mvn clean compile -e`
   - 检查依赖版本：`mvn dependency:tree`
   - 检查Java版本：`java -version`

3. **网络问题**
   - 检查网络配置：`docker network inspect erpcrm_network`
   - 测试网络连通性：`docker exec -it <container_name> ping <host>`

## 下一步计划

1. **修复所有编译错误**
2. **构建Windows兼容的Docker镜像**
3. **部署完整的后端服务**
4. **配置数据库和缓存服务**
5. **实现CI/CD流水线**
6. **配置监控和告警**

## 资源链接

- [Docker Documentation](https://docs.docker.com/)
- [Spring Boot Documentation](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/)
- [Windows Containers Documentation](https://learn.microsoft.com/en-us/virtualization/windowscontainers/)
- [Maven Documentation](https://maven.apache.org/guides/)

## 联系方式

如有任何问题，请联系ERP+CRM国铁商城系统团队。

---

*文档创建时间：2026-01-10*
*版本：1.0*
