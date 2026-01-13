# 📘 GitHub Actions 设置指南（超详细图文版）

## 🎯 目标
在GitHub上设置自动构建，让GitHub自动为您构建Windows EXE文件。

## ⏱️ 预计时间
5-10分钟

## 📋 操作步骤

### 步骤1：打开GitHub仓库

1. **打开浏览器**（Chrome、Edge、Firefox都可以）

2. **访问仓库地址**：
   ```
   https://github.com/longlong1004/erpcrm-flutter-client
   ```

3. **您应该看到**：
   - 仓库名称：`erpcrm-flutter-client`
   - 很多文件和文件夹
   - 顶部有：Code、Issues、Pull requests、**Actions** 等标签

---

### 步骤2：进入Actions页面

1. **点击顶部的 "Actions" 标签**
   - 位置：在仓库名称下方，Code 和 Issues 之间
   - 如果看不到，可能需要先登录GitHub账号

2. **您会看到**：
   - 一个绿色的按钮："Set up a workflow yourself"
   - 或者："Get started with GitHub Actions"

3. **点击绿色按钮 "Set up a workflow yourself"**
   - 或者点击 "New workflow" 按钮

---

### 步骤3：创建Workflow文件

1. **您会进入一个代码编辑页面**
   - 页面标题：`.github/workflows/main.yml`
   - 中间有一个大的文本编辑框

2. **删除编辑框中的所有内容**
   - 按 `Ctrl+A`（Windows）或 `Cmd+A`（Mac）全选
   - 按 `Delete` 删除

3. **打开项目中的 `workflow-config.yml` 文件**
   - 回到仓库首页
   - 找到并点击 `workflow-config.yml` 文件
   - 点击右上角的 "Raw" 按钮
   - 按 `Ctrl+A` 全选
   - 按 `Ctrl+C` 复制

4. **回到workflow编辑页面**
   - 在空白的编辑框中按 `Ctrl+V` 粘贴

5. **修改文件名**（可选）
   - 将 `main.yml` 改为 `build-windows.yml`
   - 位置：页面顶部的文件名输入框

---

### 步骤4：保存并提交

1. **点击右上角的绿色按钮 "Commit changes..."**

2. **在弹出的对话框中**：
   - 标题（Commit message）：可以保持默认，或输入 "Add Windows build workflow"
   - 描述（Extended description）：可以留空
   - 选择 "Commit directly to the master branch"（默认已选中）

3. **点击绿色按钮 "Commit changes"**

---

### 步骤5：等待构建完成

1. **自动跳转到Actions页面**
   - 您会看到一个黄色圆点图标，表示正在构建
   - 旁边显示 "Add Windows build workflow" 或您输入的提交信息

2. **点击这个构建任务**
   - 可以看到详细的构建过程

3. **等待构建完成**
   - 黄色圆点 🟡 = 正在构建（预计30-40分钟）
   - 绿色对勾 ✅ = 构建成功
   - 红色叉号 ❌ = 构建失败（如果失败，请联系我）

---

### 步骤6：下载EXE文件

**如果构建成功（绿色对勾）：**

#### 方法1：从Artifacts下载

1. **在构建任务页面向下滚动**
2. **找到 "Artifacts" 部分**
3. **点击 "erpcrm-windows-x64"**
4. **自动下载 `erpcrm-windows-x64.zip` 文件**

#### 方法2：从Releases下载

1. **回到仓库首页**
2. **点击右侧的 "Releases"**
3. **点击最新的版本（如 v1.0.1）**
4. **在 "Assets" 下找到 `erpcrm-windows-x64.zip`**
5. **点击下载**

---

### 步骤7：解压并运行

1. **找到下载的 `erpcrm-windows-x64.zip` 文件**

2. **右键点击 → 解压缩**
   - 或使用7-Zip、WinRAR等工具

3. **进入解压后的文件夹**

4. **双击 `erpcrm_client.exe` 运行程序**

---

## ❓ 常见问题

### Q1: 找不到 "Actions" 标签？
**A**: 可能需要先登录GitHub账号。

### Q2: 构建失败了怎么办？
**A**: 
1. 点击失败的构建任务
2. 查看红色的错误信息
3. 截图发给我，我会帮您修复

### Q3: 构建需要多长时间？
**A**: 首次构建约30-40分钟，后续构建会更快（10-15分钟）。

### Q4: 下载的文件无法运行？
**A**: 
1. 确保解压了整个文件夹
2. 不要只复制.exe文件
3. 需要整个文件夹中的所有文件

### Q5: 如何重新构建？
**A**: 
1. 进入Actions页面
2. 点击左侧的 "Build Windows EXE"
3. 点击右上角的 "Run workflow"
4. 点击绿色按钮 "Run workflow"

---

## 📞 需要帮助？

如果遇到任何问题：
1. 截图当前页面
2. 告诉我您在哪一步遇到问题
3. 我会立即帮您解决

---

## 🎉 完成！

按照以上步骤操作后，您就能得到自动构建的Windows EXE文件了！

**仓库地址**: https://github.com/longlong1004/erpcrm-flutter-client
