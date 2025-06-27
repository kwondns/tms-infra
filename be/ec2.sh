#!/bin/bash
yum update -y
yum install -y ruby wget git

# SSH PORT 변경
sed -i '/^Port /d' /etc/ssh/sshd_config
echo "Port 9981" >> /etc/ssh/sshd_config
systemctl restart sshd

# CodeDeploy agent 설치
cd /home/ec2-user
wget https://aws-codedeploy-${region}.s3.${region}.amazonaws.com/latest/install
chmod +x ./install
./install auto
systemctl start codedeploy-agent
systemctl enable codedeploy-agent

# NestJS 설치
curl -sL https://rpm.nodesource.com/setup_20.x | bash -
yum install -y nodejs
npm install -g yarn
npm install -g @nestjs/cli
npm install pm2@latest -g

# Redis 설치 (BullMQ용)
sudo dnf update -y
sudo dnf install redis6 -y
sudo systemctl enable redis6
sudo systemctl start redis6

# Redis가 잘 설치/실행됐는지 확인 로그
systemctl status redis6

# 설치 버전 확인
node -v
npm -v
yarn -v
pm2 -v
redis6-cli ping
