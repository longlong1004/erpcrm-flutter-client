# 第一阶段：构建阶�?FROM maven:3.9.4-eclipse-temurin-17 AS builder

WORKDIR /app

# 复制pom.xml和源代码
COPY pom.xml .
COPY src ./src

# 构建项目
RUN mvn clean package -DskipTests

# 第二阶段：运行阶�?FROM openjdk:17-alpine

WORKDIR /app

# 从构建阶段复制jar文件
COPY --from=builder /app/target/erpcrm-server-1.0.0-SNAPSHOT.jar app.jar

# 暴露端口
EXPOSE 8080

# 启动应用
ENTRYPOINT ["java", "-jar", "app.jar"]
