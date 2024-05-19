#!/bin/bash
# 将环境变量保存到 /etc/environment
printenv > /etc/environment

# 启动 SSH 服务
exec /usr/sbin/sshd -D
