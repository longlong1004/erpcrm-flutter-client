# 第一阶段：构建阶段
FROM maven:3.9.4-eclipse-temurin-17 AS builder

LABEL maintainer="ERP+CRM国铁商城系统团队"

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

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]