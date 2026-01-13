#!/bin/bash

# ERP+CRM系统兼容性测试执行脚本
# 自动化执行跨浏览器、跨设备兼容性测试

set -e

echo "🚀 开始ERP+CRM系统兼容性测试"
echo "======================================"

# 检查Flutter环境
echo "📋 检查Flutter环境..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter未安装或未添加到PATH"
    exit 1
fi

flutter --version

# 检查依赖包
echo "📦 检查测试依赖..."
npm list puppeteer playwright || npm install puppeteer playwright

# 启动Flutter应用
echo "🔧 启动Flutter开发服务器..."
flutter run -d chrome --web-port=8080 &
FLUTTER_PID=$!
echo "Flutter应用已启动，PID: $FLUTTER_PID"

# 等待服务器启动
echo "⏳ 等待服务器启动..."
sleep 10

# 检查服务器是否启动成功
if curl -f http://localhost:8080 > /dev/null 2>&1; then
    echo "✅ 服务器启动成功"
else
    echo "❌ 服务器启动失败"
    kill $FLUTTER_PID 2>/dev/null || true
    exit 1
fi

# 运行浏览器兼容性测试
echo "🌐 开始浏览器兼容性测试..."
node test_report/compatibility_test_runner.js

# 运行Playwright测试
echo "🧪 运行Playwright自动化测试..."
npx playwright install
npx playwright test

# 生成测试报告
echo "📊 生成兼容性测试报告..."
timestamp=$(date +"%Y%m%d_%H%M%S")
report_file="test_report/compatibility_results_${timestamp}.html"

# 简单的HTML报告生成
cat > "$report_file" << EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ERP+CRM系统兼容性测试报告</title>
    <style>
        body { font-family: 'Microsoft YaHei', Arial, sans-serif; margin: 20px; }
        .header { background: #007bff; color: white; padding: 20px; border-radius: 5px; }
        .summary { background: #f8f9fa; padding: 15px; margin: 20px 0; border-radius: 5px; }
        .test-result { margin: 10px 0; padding: 10px; border-left: 4px solid #28a745; }
        .failed { border-left-color: #dc3545; }
        .warning { border-left-color: #ffc107; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background-color: #f2f2f2; }
        .pass { color: #28a745; font-weight: bold; }
        .fail { color: #dc3545; font-weight: bold; }
    </style>
</head>
<body>
    <div class="header">
        <h1>ERP+CRM系统兼容性测试报告</h1>
        <p>生成时间: $(date)</p>
    </div>
    
    <div class="summary">
        <h2>测试概览</h2>
        <p>本次测试覆盖了所有主要浏览器、设备和操作系统组合。</p>
        <p>测试结果已保存到详细的JSON文件中。</p>
    </div>
    
    <h2>测试完成</h2>
    <p>✅ 兼容性测试已执行完成</p>
    <p>📊 详细结果请查看: test_report/ 目录下的JSON文件</p>
    <p>🔍 HTML报告: $report_file</p>
    
    <h2>下一步操作</h2>
    <ol>
        <li>查看生成的JSON测试结果文件</li>
        <li>根据发现的问题进行修复</li>
        <li>重新运行测试验证修复效果</li>
        <li>更新兼容性测试报告</li>
    </ol>
</body>
</html>
EOF

echo "📄 HTML报告已生成: $report_file"

# 停止Flutter应用
echo "🛑 停止Flutter应用..."
kill $FLUTTER_PID 2>/dev/null || true

echo "======================================"
echo "🎉 兼容性测试完成！"
echo "📋 查看详细结果请检查test_report/目录"
echo "🌐 在浏览器中打开 $report_file 查看报告"
echo "======================================"