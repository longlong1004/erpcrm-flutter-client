# ERP+CRM系统后端修复脚本
# 请以管理员身份运行此脚本

# 设置变量
$SERVER_DIR = "h:\erpcrm\server"
$CLIENT_DIR = "h:\erpcrm\client"

Write-Host "开始修复ERP+CRM系统后端..."

# 1. 修复pom.xml文件
Write-Host "1. 修复pom.xml文件，添加缺失的依赖..."

try {
    # 读取原始pom.xml内容
    $pomContent = Get-Content -Path "$SERVER_DIR\pom.xml" -Raw
    
    # 替换Utils部分，添加缺失的依赖
    $newPomContent = $pomContent -replace "        <!-- Utils -->
        <!-- Utils -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>

        <!-- MapStruct annotation processor -->" , "        <!-- Utils -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        
        <!-- ModelMapper -->
        <dependency>
            <groupId>org.modelmapper</groupId>
            <artifactId>modelmapper</artifactId>
            <version>3.2.0</version>
        </dependency>
        
        <!-- MyBatis Plus -->
        <dependency>
            <groupId>com.baomidou</groupId>
            <artifactId>mybatis-plus-boot-starter</artifactId>
            <version>3.5.5</version>
        </dependency>
        
        <!-- MyBatis -->
        <dependency>
            <groupId>org.mybatis</groupId>
            <artifactId>mybatis</artifactId>
            <version>3.5.16</version>
        </dependency>

        <!-- MapStruct annotation processor -->"
    
    # 保存修改后的pom.xml
    Set-Content -Path "$SERVER_DIR\pom.xml" -Value $newPomContent
    Write-Host "   ✅ pom.xml修复成功！"
} catch {
    Write-Host "   ❌ pom.xml修复失败：$($_.Exception.Message)"
    Write-Host "   请手动按照以下内容修改$SERVER_DIR\pom.xml文件："
    Write-Host "   在<dependency>lombok</dependency>之后添加："
    Write-Host "   <!-- ModelMapper -->
        <dependency>
            <groupId>org.modelmapper</groupId>
            <artifactId>modelmapper</artifactId>
            <version>3.2.0</version>
        </dependency>
        
        <!-- MyBatis Plus -->
        <dependency>
            <groupId>com.baomidou</groupId>
            <artifactId>mybatis-plus-boot-starter</artifactId>
            <version>3.5.5</version>
        </dependency>
        
        <!-- MyBatis -->
        <dependency>
            <groupId>org.mybatis</groupId>
            <artifactId>mybatis</artifactId>
            <version>3.5.16</version>
        </dependency>"
}

# 2. 修复LogisticsTrace.java文件
Write-Host "\n2. 修复LogisticsTrace.java文件，移除index()方法..."

try {
    $logisticsTracePath = "$SERVER_DIR\src\main\java\com\erpcrm\server\model\logistics\LogisticsTrace.java"
    $logisticsTraceContent = Get-Content -Path $logisticsTracePath -Raw
    $newLogisticsTraceContent = $logisticsTraceContent -replace "@Column\(name = \"logistics_id\", nullable = false, index = true\)", "@Column(name = \"logistics_id\", nullable = false)"
    Set-Content -Path $logisticsTracePath -Value $newLogisticsTraceContent
    Write-Host "   ✅ LogisticsTrace.java修复成功！"
} catch {
    Write-Host "   ❌ LogisticsTrace.java修复失败：$($_.Exception.Message)"
    Write-Host "   请手动修改$logisticsTracePath文件："
    Write-Host "   将@Column(name = \"logistics_id\", nullable = false, index = true)"
    Write-Host "   修改为：@Column(name = \"logistics_id\", nullable = false)"
}

Write-Host "\n修复完成！请按照以下步骤继续："
Write-Host "1. 打开PowerShell，导航到$SERVER_DIR目录"
Write-Host "2. 运行命令：mvn clean package -DskipTests"
Write-Host "3. 如果编译成功，导航到$CLIENT_DIR目录"
Write-Host "4. 运行命令：docker-compose -f docker-compose-simple.yml up -d"
Write-Host "\n详细修复指南请参考：$CLIENT_DIR\后端编译修复指南.md"
