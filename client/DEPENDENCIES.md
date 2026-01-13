# 仪表盘所需依赖配置

## 需要添加到 pubspec.yaml 的依赖

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 现有依赖（保持不变）
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.7
  intl: ^0.19.0
  logger: ^2.4.0
  
  # 新增依赖
  fl_chart: ^0.69.0  # 图表库

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # 现有开发依赖（保持不变）
  hive_generator: ^2.0.1
  build_runner: ^2.4.12
```

## 依赖说明

### fl_chart
- **用途**：数据可视化图表库
- **版本**：0.69.0
- **功能**：
  - 折线图（Line Chart）
  - 柱状图（Bar Chart）
  - 饼图（Pie Chart）
  - 散点图（Scatter Chart）
  - 支持动画和交互
- **文档**：https://pub.dev/packages/fl_chart

### 其他依赖说明

#### hive & hive_flutter
- **用途**：本地数据库存储
- **说明**：项目已有，用于存储订单、客户等业务数据

#### flutter_riverpod
- **用途**：状态管理
- **说明**：项目已有，用于管理应用状态

#### go_router
- **用途**：路由管理
- **说明**：项目已有，用于页面导航

#### intl
- **用途**：国际化和日期格式化
- **说明**：项目已有，用于日期时间格式化

#### logger
- **用途**：日志记录
- **说明**：项目已有，用于调试和错误追踪

## 安装步骤

1. 将上述依赖添加到 `pubspec.yaml` 文件中
2. 运行以下命令安装依赖：

```bash
flutter pub get
```

3. 如果使用 Hive 生成器，运行：

```bash
flutter pub run build_runner build
```

## 注意事项

1. **fl_chart 版本兼容性**
   - 确保 Flutter SDK 版本 >= 3.0.0
   - 如果遇到版本冲突，可以尝试使用 `flutter pub upgrade`

2. **图表性能优化**
   - 对于大量数据点（>100个），建议进行数据采样
   - 使用 `RepaintBoundary` 包裹图表以提高性能

3. **日期选择器本地化**
   - 需要在 `MaterialApp` 中配置 `localizationsDelegates`
   - 确保添加了中文本地化支持

## 可选依赖

如果需要更多功能，可以考虑添加以下依赖：

```yaml
dependencies:
  # 数据导出
  excel: ^4.0.6  # Excel 导出
  pdf: ^3.11.1   # PDF 导出
  
  # 文件选择和保存
  file_picker: ^8.1.4
  path_provider: ^2.1.5
  
  # 数据表格
  data_table_2: ^2.5.15
  
  # 图表增强
  syncfusion_flutter_charts: ^27.2.5  # 更强大的图表库（商业许可）
```

## 完整的 pubspec.yaml 示例

```yaml
name: erpcrm_client
description: ERP/CRM 客户端应用
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # 核心依赖
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.7
  intl: ^0.19.0
  logger: ^2.4.0
  
  # 图表
  fl_chart: ^0.69.0
  
  # UI 组件
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  flutter_lints: ^5.0.0
  hive_generator: ^2.0.1
  build_runner: ^2.4.12

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
  
  fonts:
    - family: Roboto
      fonts:
        - asset: fonts/Roboto-Regular.ttf
        - asset: fonts/Roboto-Bold.ttf
          weight: 700
```
