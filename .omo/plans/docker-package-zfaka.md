# Docker 打包与发布实施计划

## 目标

为 ZFAKA 创建可部署的 Docker 运行时和 GitHub Actions 发布流程，镜像发布到 `ghcr.io/abai569/flox-zfaka`，标签使用 `1.4.9` 与 `latest`。

## 安全边界

- `conf/application.ini` 不进入构建上下文，避免泄露线上数据库凭据。
- `install/ka_abai_eu_org.sql` 仅作为结构参考，不进入镜像。
- `install/faka.sql` 不直接作为生产数据导入源。
- 生成 `install/docker-seed.sql`，只保留 schema、基础配置分类和用户组；管理员、支付、订单、邮件、商品及卡密数据由运行时初始化或保持为空。
- `.env`、日志、上传目录、vendor、备份、截图和父工作区杂项不进入镜像。

## 实施项

1. 生成安全的 `install/docker-seed.sql`。
2. 添加 `conf/application.ini.template`，使用环境变量渲染数据库连接和应用目录。
3. 添加 Dockerfile、Nginx 配置、Supervisor 配置和 entrypoint。
4. 添加 `docker-compose.yml`、`.env.example` 和 Docker 安装脚本。
5. 添加 GitHub Actions buildx 多架构发布工作流，推送 `linux/amd64` 与 `linux/arm64`。
6. 更新源码版本为 `1.4.9`，并确保 `ADMIN_DIR` 可由环境变量控制。
7. 为 `/var/www/html/install` 使用独立命名卷，持久化 `install.lock`，避免容器重建后重复导入 seed。
8. 执行敏感文件扫描、SQL 内容检查、JavaScript/CSS 静态检查及 Docker 构建/启动 smoke test；缺少 Docker 或外部凭据时明确记录阻塞。

## 运行时约定

- Web 容器监听 80 端口，由 Nginx 转发 PHP 请求到 PHP-FPM。
- 数据库使用 MySQL 8.0，数据存储在命名卷。
- 首次启动由 entrypoint 渲染配置、导入 seed、创建 install lock，并生成管理员账号；`install.lock` 保存在 `install_data` 命名卷中。
- 管理员参数通过 `ADMIN_EMAIL`、`ADMIN_PASSWORD` 和 `ADMIN_DIR` 注入。
- 默认数据库名为 `zfaka`，默认容器端口为 `8089`。

## 完成标准

- 构建上下文不包含真实配置和生产 SQL。
- PHP 应用配置不再依赖 `/www/wwwroot/ka.abai.eu.org`。
- 首次启动能完成数据库初始化并访问应用入口。
- GHCR 工作流仅在 `v1.4.9` 标签推送时发布镜像。

## QA 命令与验收标准

### Compose 配置

```sh
docker compose --env-file .env.example config
```

验收：命令退出码为 0，且 `web` 服务包含 `install_data:/var/www/html/install` 挂载。

### 敏感文件边界

```sh
rg -n --hidden --glob '!vendor/**' --glob '!.git/**' \
  '86YrNDFSjxYyEtnc|abaibubaix@gmail.com|140.150.236.185|f6f22a19948eaf991c17382f70daebb8|/www/wwwroot/ka.abai.eu.org' \
  Dockerfile .dockerignore docker docker-compose.yml conf/application.ini.template install/docker-seed.sql
```

验收：命令无输出；生产配置、生产 SQL 和凭据不出现在 Docker 相关输入文件中。

### 镜像构建

```sh
docker build --no-cache -t zfaka:qa .
```

验收：命令退出码为 0，镜像包含 PHP-FPM、Nginx、Supervisor、Yaf 和 Composer 依赖。

### 首次启动与数据库初始化

```sh
docker compose --env-file .env.example up -d --build
docker compose ps
curl -fsS http://127.0.0.1:8089/
docker compose exec db sh -c 'mysql -uzfaka -p"$${MYSQL_PASSWORD}" -e "SHOW TABLES FROM $${MYSQL_DATABASE};"'
docker compose exec web test -s /var/www/html/install/install.lock
```

验收：两个服务为 healthy/running，HTTP 返回成功，数据库包含 seed 表，且 `install.lock` 存在且非空。

### 重启幂等性

```sh
docker compose --env-file .env.example restart web
docker compose exec web test -s /var/www/html/install/install.lock
docker compose logs --no-color web
```

验收：Web 服务恢复 healthy，lock 仍存在，日志没有重复导入 seed 或重复管理员初始化错误。

### 清理

```sh
docker compose down
```

验收：服务停止；不使用 `-v`，以保留数据库、上传文件、日志和初始化 lock。

### 版本与后台目录

```sh
rg -n "ZFAKA_VERSION|ADMIN_DIR|1\.4\.9" application/init.php conf/application.ini.template docker-compose.yml Dockerfile
```

验收：`application/init.php` 从环境变量读取 `ZFAKA_VERSION` 与 `ADMIN_DIR`，并分别使用 `1.4.9` 与 `Admin` 作为默认值；Compose 默认版本为 `1.4.9`。使用 `ADMIN_DIR=CustomAdmin` 启动时，entrypoint 将后台模块目录改为 `CustomAdmin`，并渲染配置中的应用目录。

```sh
docker compose --env-file .env.example run --rm -e ADMIN_DIR=CustomAdmin web sh -c 'test -d /var/www/html/application/modules/CustomAdmin && grep -q ",CustomAdmin," /var/www/html/conf/application.ini'
```

验收：命令退出码为 0，说明后台模块目录和配置均响应 `ADMIN_DIR`。

### JavaScript 与 CSS 静态检查

```sh
node --check public/static/js/jquery.min.js
node --check public/static/js/layer/layer.js
node --check public/static/js/layui/layui.js
```

```sh
powershell -NoProfile -Command "$files = Get-ChildItem -Path 'public' -Filter '*.css' -Recurse; foreach ($file in $files) { $text = Get-Content -Raw -LiteralPath $file.FullName; if (($text.ToCharArray() | Where-Object { $_ -eq '{' }).Count -ne ($text.ToCharArray() | Where-Object { $_ -eq '}' }).Count) { throw \"Unbalanced CSS braces: $($file.FullName)\" } }"
```

验收：Node 语法检查退出码为 0，CSS 检查不报告不平衡文件。

### GitHub Actions 与多架构镜像

```sh
rg -n "tags:|platforms: linux/amd64,linux/arm64|push: true" .github/workflows/docker.yml
```

验收：工作流只声明 `v*` tag push 触发器，不包含 `workflow_dispatch`，并使用 Buildx 推送固定的版本标签与 `latest`；发布 `v1.4.9` 后执行以下命令：

```sh
docker buildx imagetools inspect ghcr.io/abai569/flox-zfaka:1.4.9
docker buildx imagetools inspect ghcr.io/abai569/flox-zfaka:latest
```

验收：两个 tag 均存在，并显示 `linux/amd64` 和 `linux/arm64` 平台清单。
