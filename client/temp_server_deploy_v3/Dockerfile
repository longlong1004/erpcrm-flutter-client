# 绗竴闃舵锛氭瀯寤洪樁娈?FROM maven:3.9.4-eclipse-temurin-17 AS builder

WORKDIR /app

# 澶嶅埗pom.xml鍜屾簮浠ｇ爜
COPY pom.xml .
COPY src ./src

# 鏋勫缓椤圭洰
RUN mvn clean package -DskipTests

# 绗簩闃舵锛氳繍琛岄樁娈?FROM openjdk:17-alpine

WORKDIR /app

# 浠庢瀯寤洪樁娈靛鍒秊ar鏂囦欢
COPY --from=builder /app/target/erpcrm-server-1.0.0-SNAPSHOT.jar app.jar

# 鏆撮湶绔彛
EXPOSE 8080

# 鍚姩搴旂敤
ENTRYPOINT ["java", "-jar", "app.jar"]
