#!/bin/bash

# 定义固定端口
FIXED_PORT=8080

# 检查端口是否被占用
check_port() {
  local port=$1
  if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

# 尝试使用固定端口启动
if check_port $FIXED_PORT; then
  echo "端口 $FIXED_PORT 已被占用，尝试终止占用该端口的进程..."
  # 终止占用端口的进程
  lsof -Pi :$FIXED_PORT -sTCP:LISTEN -t | xargs -r kill -9
  sleep 2
fi

# 再次检查端口是否可用
if check_port $FIXED_PORT; then
  echo "端口 $FIXED_PORT 仍被占用，无法启动服务"
  exit 1
fi

echo "使用固定端口 $FIXED_PORT 启动Flutter Web项目..."
flutter run -d chrome --web-port=$FIXED_PORT
