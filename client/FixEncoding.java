import java.io.*;
import java.nio.charset.*;

public class FixEncoding {
    public static void main(String[] args) {
        String filePath = "h:\\erpcrm\\server\\src\\main\\java\\com\\erpcrm\\server\\model\\logistics\\LogisticsTrace.java";
        
        try {
            // Read file content with GBK encoding to handle garbled characters
            File file = new File(filePath);
            StringBuilder content = new StringBuilder();
            
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(file), "GBK"))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    content.append(line).append(System.lineSeparator());
                }
            }
            
            // Replace garbled content with correct English messages
            String fixedContent = content.toString()
                .replaceAll(".*物流轨迹实体.*", "/**")
                .replaceAll(".*记录物流过程中的每个节点信息.*", " * Logistics trace entity class")
                .replaceAll(".*物流单号不能为空.*", " * Records each node information in the logistics process")
                .replaceAll(".*物流单号长度不能超过50个字.*", " */")
                .replaceAll(".*轨迹描述不能为空.*", "    @NotBlank(message = \"Logistics number cannot be blank\")")
                .replaceAll(".*轨迹描述长度不能超过500个字.*", "    @Size(max = 50, message = \"Logistics number cannot exceed 50 characters\")")
                .replaceAll(".*当前状态不能为.*", "    @NotBlank(message = \"Trace description cannot be blank\")")
                .replaceAll(".*当前状态长度不能超.*0个字.*", "    @Size(max = 500, message = \"Trace description cannot exceed 500 characters\")")
                .replaceAll(".*操作人不能为.*", "    @NotBlank(message = \"Current status cannot be blank\")")
                .replaceAll(".*操作人长度不能超.*00个字.*", "    @Size(max = 20, message = \"Current status cannot exceed 20 characters\")")
                .replaceAll(".*操作人电话长度不能超.*0个字.*", "    @NotBlank(message = \"Operator cannot be blank\")")
                .replaceAll(".*操作地点长度不能超过200个字.*", "    @Size(max = 100, message = \"Operator cannot exceed 100 characters\")");
            
            // Save fixed content with UTF-8 encoding
            try (BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(file), "UTF-8"))) {
                writer.write(fixedContent);
            }
            
            System.out.println("File encoding fixed successfully!");
            
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}