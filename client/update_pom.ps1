# Update pom.xml file to add missing dependencies

# Navigate to server directory
cd h:\erpcrm\server

# Read the current pom.xml content
$content = Get-Content -Path "pom.xml" -Raw

# Define the old and new content
$oldText = "        <!-- Utils -->
        <!-- Utils -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>

        <!-- MapStruct annotation processor -->"

$newText = "        <!-- Utils -->
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

# Replace the content
$newContent = $content -replace [regex]::Escape($oldText), $newText

# Save the updated content
Set-Content -Path "pom.xml" -Value $newContent

Write-Host "pom.xml updated successfully!"
