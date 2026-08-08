<p align="center">
  <img width="455" height="116" alt="FLOX-ZFAKA" src="https://github.com/user-attachments/assets/56c6e3ff-2e89-4996-b9f7-55fb0aef9ed9" />
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-1.6.2-blue" alt="version 1.6.2">
  <img src="https://img.shields.io/badge/deploy-Docker-2496ED?logo=docker" alt="Docker">
  <img src="https://img.shields.io/badge/platform-linux--amd64%20%7C%20linux--arm64-lightgrey" alt="platforms">
</p>

# Flox ZFAKA

基于 Docker 的 ZFAKA 自动售货系统，支持自动发卡、手工发卡、会员、订单、文章、邮件及多种支付渠道。

> 原项目：[ZFAKA/ZFAKA](https://github.com/ZFAKA/ZFAKA) — 本仓库在其基础上做 Docker 化部署和 Tokyo 界面适配。

本仓库只维护 Docker 部署方式。无需手动安装 Nginx、PHP、Yaf 或 MySQL，也不需要宝塔面板。

- 项目群组：[https://t.me/floxpanel](https://t.me/floxpanel)
- 作者联系：[https://t.me/abai569](https://t.me/abai569)

## 功能

- Docker 一键安装、更新、备份、恢复和卸载
- 支持 `linux/amd64` 与 `linux/arm64`
- MySQL 数据持久化
- 配置、日志、缓存和上传文件持久化
- Tokyo 前台与后台界面
- 30 项系统配置
- 10 个内置支付渠道
- 后台数据库导入与导出
- 商品多图上传、主图设置、排序和删除
- 商品详情多图缩略图与前后切换
- 后台与会员登录采用 8 小时滑动有效期，关闭浏览器后失效
- 镜像升级时自动修复基础数据，不覆盖已有支付密钥和配置值

## 环境要求

- Linux 服务器
- 使用 `root` 账号登录
- 能够访问 GitHub、GHCR 和 Docker Hub
- 默认开放端口 `8089`，安装时可以修改

安装脚本会在服务器未安装 Docker 时自动安装 Docker Engine，并自动使用 `docker compose` 或 `docker-compose`。

## 一键安装

在服务器执行：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/abai569/flox-zfaka/main/install.sh)
```

脚本会询问访问端口，直接按回车使用默认端口 `8089`。

安装目录：

```text
/opt/flox-zfaka
```

安装完成后访问：

```text
前台：http://服务器IP:8089/
后台：http://服务器IP:8089/Goadmin/login
```

默认管理员：

```text
账号：demo@demo.com
密码：admin123
```

登录后请立即在后台修改管理员账号和密码。安装生成的数据库密码保存在：

```text
/opt/flox-zfaka/.env
```

## 演示地址

前端：http://152.67.211.151:8089/

后端：http://152.67.211.151:8089/Goadmin/login

账号：`demo@demo.com`

密码：`admin123`

## 更新

建议更新前先备份：

```bash
cd /opt/flox-zfaka
bash install.sh backup
bash install.sh update
```

更新流程会：

1. 下载最新的 `docker-compose.yml`
2. 拉取最新镜像
3. 重建 Web 容器
4. 保留 MySQL、配置、日志、缓存和上传数据卷
5. 清理不再使用的旧镜像

从旧版本升级到 `v1.5.4` 时，容器会自动执行一次基础数据修复：

- 配置中心补齐并排列为标准 ID `1-30`
- 支付设置补齐并排列为标准 ID `1-10`
- 按配置名称保留已有配置值
- 按支付别名保留已有密钥、网关和激活状态
- 保留自定义配置和自定义支付渠道
- 清理配置和支付缓存

迁移成功后会写入持久化标记，不会在以后每次启动时重复执行。

升级到 `v1.5.6` 后，容器会自动创建商品图片表并迁移现有商品主图。每个商品最多可管理 10 张图片，单张图片最大 `5 MB`。

升级到 `v1.5.7` 后，商品主图固定显示在图片列表首位，前台商品详情支持多图切换；安装脚本会检测常用工具、Docker Engine 和 Docker Compose，并在支持的 Linux 发行版上自动补齐缺失软件。

## 查看状态和日志

查看容器状态：

```bash
cd /opt/flox-zfaka
bash install.sh status
```

实时查看日志：

```bash
cd /opt/flox-zfaka
bash install.sh logs
```

查看最近的 Web 容器日志：

```bash
cd /opt/flox-zfaka
docker compose logs --tail=200 zfaka-web
```

## 数据备份

### 命令行备份

```bash
cd /opt/flox-zfaka
bash install.sh backup
```

备份文件保存在：

```text
/opt/flox-zfaka/backups/
```

每次备份会生成：

- `zfaka-日期-时间.sql.gz`：MySQL 数据库备份
- `zfaka-日期-时间.env`：当前部署配置副本

数据库备份不包含 Docker 数据卷本身。迁移服务器时还应备份上传文件卷或宿主机存储。

### 后台备份

登录后台后进入：

```text
设置中心 → 数据备份
```

支持：

- 导出完整 SQL
- 上传 SQL 备份并导入
- 导入前自动生成备份
- 导入失败时自动恢复
- 下载导入前自动备份

上传文件必须是 ZFAKA SQL 备份，最大 `64 MB`。导入会覆盖当前数据库，请先确认备份可用。

## 恢复数据库

使用命令行生成的 `.sql.gz` 文件恢复：

```bash
cd /opt/flox-zfaka
bash install.sh restore /完整路径/zfaka-日期-时间.sql.gz
```

例如：

```bash
cd /opt/flox-zfaka
bash install.sh restore /opt/flox-zfaka/backups/zfaka-20260807-120000.sql.gz
```

恢复会覆盖当前数据库。操作前建议再创建一次备份。

## 修改端口

编辑部署配置：

```bash
cd /opt/flox-zfaka
nano .env
```

修改：

```text
ZFAKA_PORT=8089
```

然后重建容器：

```bash
docker compose up -d
```

## 反向代理

容器默认监听服务器的 `ZFAKA_PORT`。使用域名时，可在宿主机的 Nginx、Caddy 或其他反向代理中将请求转发到：

```text
http://127.0.0.1:8089
```

HTTPS 证书应由宿主机反向代理或外部网关管理，容器内部不负责签发证书。

## 卸载

只删除容器，保留数据库和其他数据卷：

```bash
cd /opt/flox-zfaka
bash install.sh uninstall
```

彻底删除容器、数据卷和安装目录：

```bash
cd /opt/flox-zfaka
bash install.sh uninstall --volumes
```

`--volumes` 会永久删除数据库、配置、日志、缓存和上传文件，执行前务必备份。

## 常用文件

```text
/opt/flox-zfaka/.env                 部署配置和密码
/opt/flox-zfaka/docker-compose.yml   Docker Compose 配置
/opt/flox-zfaka/install.sh           管理脚本
/opt/flox-zfaka/backups/             命令行数据库备份
```

## Docker 数据卷

```text
zfaka_mysql      MySQL 数据
zfaka_conf       应用数据库连接配置
zfaka_install    安装与迁移状态
zfaka_logs       应用日志
zfaka_temp       缓存和后台自动备份
zfaka_uploads    用户上传文件
```

实际卷名可能带有 Docker Compose 项目前缀，可通过下面的命令查看：

```bash
docker volume ls | grep zfaka
```

## 支付渠道

全新安装会创建 10 个未激活的支付渠道：

1. 支付宝当面付
2. 支付宝电脑网站支付
3. 微信扫码支付
4. 微信 H5 支付
5. PayPal
6. V 免签微信
7. V 免签支付宝
8. U 支付
9. 易支付
10. GMPay USDT

请在后台的“设置中心 → 支付设置”中填写对应渠道参数并手动激活。仓库和镜像不包含生产支付密钥。

## 安全建议

- 首次登录后立即修改默认管理员账号和密码
- 不要公开 `/opt/flox-zfaka/.env`
- 不要将数据库端口暴露到公网
- 定期执行数据库备份并下载到其他存储位置
- 使用域名时启用 HTTPS
- 更新前先备份数据库

## 免责声明

本项目仅用于技术交流。使用者应自行确保部署和业务符合当地法律法规，并自行承担使用、配置、支付渠道及数据安全相关责任。
