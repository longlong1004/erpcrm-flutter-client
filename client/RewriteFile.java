import java.io.*;

public class RewriteFile {
    public static void main(String[] args) {
        String filePath = "h:\\erpcrm\\server\\src\\main\\java\\com\\erpcrm\\server\\model\\logistics\\LogisticsTrace.java";
        
        try {
            // Create the fixed content as a string
            String fixedContent = "package com.erpcrm.server.model.logistics;\n\n" +
                "import lombok.Data;\n" +
                "import lombok.NoArgsConstructor;\n" +
                "import lombok.AllArgsConstructor;\n" +
                "import lombok.Builder;\n\n" +
                "import jakarta.persistence.*;\n" +
                "import jakarta.validation.constraints.NotBlank;\n" +
                "import jakarta.validation.constraints.Size;\n\n" +
                "import java.time.LocalDateTime;\n\n" +
                "/**\n" +
                " * Logistics trace entity class\n" +
                " * Records each node information in the logistics process\n" +
                " */\n" +
                "@Data\n" +
                "@NoArgsConstructor\n" +
                "@AllArgsConstructor\n" +
                "@Builder\n" +
                "@Entity\n" +
                "@Table(name = \"logistics_trace\", indexes = {\n" +
                "    @Index(name = \"idx_logistics_no\", columnList = \"logistics_no\")\n" +
                "})\n" +
                "public class LogisticsTrace {\n\n" +
                "    @Id\n" +
                "    @GeneratedValue(strategy = GenerationType.IDENTITY)\n" +
                "    private Long id;\n\n" +
                "    @NotBlank(message = \"Logistics number cannot be blank\")\n" +
                "    @Size(max = 50, message = \"Logistics number cannot exceed 50 characters\")\n" +
                "    @Column(name = \"logistics_no\", nullable = false)\n" +
                "    private String logisticsNo;\n\n" +
                "    @NotBlank(message = \"Trace description cannot be blank\")\n" +
                "    @Size(max = 500, message = \"Trace description cannot exceed 500 characters\")\n" +
                "    @Column(name = \"description\", nullable = false)\n" +
                "    private String description;\n\n" +
                "    @NotBlank(message = \"Current status cannot be blank\")\n" +
                "    @Size(max = 20, message = \"Current status cannot exceed 20 characters\")\n" +
                "    @Column(name = \"current_status\", nullable = false)\n" +
                "    private String currentStatus;\n\n" +
                "    @NotBlank(message = \"Operator cannot be blank\")\n" +
                "    @Size(max = 100, message = \"Operator cannot exceed 100 characters\")\n" +
                "    @Column(name = \"operator\", nullable = false)\n" +
                "    private String operator;\n\n" +
                "    @Size(max = 20, message = \"Operator phone cannot exceed 20 characters\")\n" +
                "    @Column(name = \"operator_phone\")\n" +
                "    private String operatorPhone;\n\n" +
                "    @Size(max = 200, message = \"Location cannot exceed 200 characters\")\n" +
                "    @Column(name = \"location\")\n" +
                "    private String location;\n\n" +
                "    @Column(name = \"create_time\")\n" +
                "    private LocalDateTime createTime;\n\n" +
                "    @Column(name = \"update_time\")\n" +
                "    private LocalDateTime updateTime;\n\n" +
                "    @PrePersist\n" +
                "    protected void onCreate() {\n" +
                "        createTime = LocalDateTime.now();\n" +
                "        updateTime = LocalDateTime.now();\n" +
                "    }\n\n" +
                "    @PreUpdate\n" +
                "    protected void onUpdate() {\n" +
                "        updateTime = LocalDateTime.now();\n" +
                "    }\n" +
                "}";
            
            // Write the fixed content to the file using UTF-8 encoding
            try (BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(filePath), "UTF-8"))) {
                writer.write(fixedContent);
            }
            
            System.out.println("File rewritten successfully!");
            
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}