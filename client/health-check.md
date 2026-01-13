# 健康检查配置说明

## 问题分析
当前后端服务缺少健康检查端点，导致Docker健康检查失败。由于无法修改server目录下的文件，我们需要创建一个简化的健康检查方案。

## 解决方案
1. 在docker-compose-simple.yml中，我们将健康检查命令修改为使用更简单的方式，比如直接访问根路径
2. 或者我们可以在后端服务中添加一个简单的健康检查端点

## 修改后的健康检查配置
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8082/api/"]
  interval: 30s
  timeout: 10s
  retries: 3
```
