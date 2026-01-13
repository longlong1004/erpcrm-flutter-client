# ERP+CRM系统后端修复脚本（简化版）
# 请以管理员身份运行此脚本

$SERVER_DIR = 'h:\erpcrm\server'
$CLIENT_DIR = 'h:\erpcrm\client'

Write-Host '开始修复ERP+CRM系统后端...'

# 1. 显示pom.xml修复说明
Write-Host '1. pom.xml文件修复说明：'
Write-Host '   请手动修改' $SERVER_DIR '\pom.xml文件，在lombok依赖之后添加以下内容：'
Write-Host ''
Write-Host '<!-- ModelMapper -->'
Write-Host '<dependency>'
Write-Host '    <groupId>org.modelmapper</groupId>'
Write-Host '    <artifactId>modelmapper</artifactId>'
Write-Host '    <version>3.2.0</version>'
Write-Host '</dependency>'
Write-Host ''
Write-Host '<!-- MyBatis Plus -->'
Write-Host '<dependency>'
Write-Host '    <groupId>com.baomidou</groupId>'
Write-Host '    <artifactId>mybatis-plus-boot-starter</artifactId>'
Write-Host '    <version>3.5.5</version>'
Write-Host '</dependency>'
Write-Host ''
Write-Host '<!-- MyBatis -->'
Write-Host '<dependency>'
Write-Host '    <groupId>org.mybatis</groupId>'
Write-Host '    <artifactId>mybatis</artifactId>'
Write-Host '    <version>3.5.16</version>'
Write-Host '</dependency>'
Write-Host ''

# 2. 显示LogisticsTrace.java修复说明
Write-Host '2. LogisticsTrace.java文件修复说明：'
Write-Host '   请手动修改' $SERVER_DIR '\src\main\java\com\erpcrm\server\model\logistics\LogisticsTrace.java文件：'
Write-Host ''
Write-Host '   将：@Column(name = "logistics_id", nullable = false, index = true)'
Write-Host '   修改为：@Column(name = "logistics_id", nullable = false)'
Write-Host ''

# 3. 显示后续步骤
Write-Host '修复完成后，请按照以下步骤继续：'
Write-Host '1. 打开PowerShell，导航到' $SERVER_DIR '目录'
Write-Host '2. 运行命令：mvn clean package -DskipTests'
Write-Host '3. 如果编译成功，导航到' $CLIENT_DIR '目录'
Write-Host '4. 运行命令：docker-compose -f docker-compose-simple.yml up -d'
Write-Host ''
Write-Host '详细修复指南请参考：' $CLIENT_DIR '\后端编译修复指南.md'
