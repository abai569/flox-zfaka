SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS `t_admin_login_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `adminid` int NOT NULL DEFAULT 0,
  `ip` varchar(55) NOT NULL DEFAULT '',
  `addtime` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_admin_user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL DEFAULT '',
  `password` varchar(255) NOT NULL DEFAULT '',
  `secret` varchar(55) NOT NULL DEFAULT '',
  `updatetime` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_config_cat` (
  `id` int NOT NULL AUTO_INCREMENT,
  `catname` varchar(32) NOT NULL DEFAULT '',
  `catkey` varchar(32) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_config` (
  `id` int NOT NULL AUTO_INCREMENT,
  `catid` int NOT NULL DEFAULT 1,
  `name` varchar(32) NOT NULL DEFAULT '',
  `value` text NOT NULL,
  `tag` text NOT NULL,
  `lock` tinyint(1) NOT NULL DEFAULT 0,
  `updatetime` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_email` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sendmail` varchar(255) NOT NULL DEFAULT '',
  `sendname` varchar(255) NOT NULL DEFAULT '',
  `protocol` varchar(255) NOT NULL DEFAULT 'smtp',
  `host` varchar(255) NOT NULL DEFAULT '',
  `port` varchar(55) NOT NULL DEFAULT '',
  `mailaddress` varchar(255) NOT NULL DEFAULT '',
  `mailpassword` varchar(255) NOT NULL DEFAULT '',
  `smtp_crypto` tinyint(1) NOT NULL DEFAULT 0,
  `isactive` tinyint(1) NOT NULL DEFAULT 1,
  `isdelete` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_email_code` (
  `id` int NOT NULL AUTO_INCREMENT,
  `action` varchar(50) NOT NULL DEFAULT '',
  `userid` int NOT NULL DEFAULT 0,
  `email` varchar(255) NOT NULL DEFAULT '',
  `code` varchar(50) NOT NULL DEFAULT '',
  `ip` varchar(50) NOT NULL DEFAULT '',
  `result` text NOT NULL,
  `addtime` int NOT NULL DEFAULT 0,
  `status` tinyint(1) NOT NULL DEFAULT 0,
  `checkedStatus` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_email_queue` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL DEFAULT '',
  `subject` varchar(255) NOT NULL DEFAULT '',
  `content` text NOT NULL,
  `addtime` int NOT NULL DEFAULT 0,
  `sendtime` int NOT NULL DEFAULT 0,
  `sendresult` text NOT NULL,
  `status` tinyint(1) NOT NULL DEFAULT 0,
  `isdelete` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_help` (
  `id` int NOT NULL AUTO_INCREMENT,
  `typeid` int NOT NULL DEFAULT 1,
  `title` varchar(255) NOT NULL DEFAULT '',
  `content` text NOT NULL,
  `isactive` tinyint(1) NOT NULL DEFAULT 1,
  `addtime` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_order` (
  `id` int NOT NULL AUTO_INCREMENT,
  `orderid` varchar(55) NOT NULL DEFAULT '0',
  `userid` int NOT NULL DEFAULT 0,
  `email` varchar(255) NOT NULL DEFAULT '',
  `qq` varchar(50) NOT NULL DEFAULT '',
  `pid` int NOT NULL DEFAULT 0,
  `productname` varchar(255) NOT NULL DEFAULT '',
  `price` decimal(10,2) NOT NULL DEFAULT 0.00,
  `number` int NOT NULL DEFAULT 0,
  `money` decimal(10,2) NOT NULL DEFAULT 0.00,
  `chapwd` varchar(55) NOT NULL DEFAULT '',
  `ip` varchar(55) NOT NULL DEFAULT '',
  `status` tinyint NOT NULL DEFAULT 0,
  `addtime` int NOT NULL DEFAULT 0,
  `paytime` int NOT NULL DEFAULT 0,
  `tradeid` varchar(255) NOT NULL DEFAULT '',
  `paymethod` varchar(255) NOT NULL DEFAULT '',
  `paymoney` decimal(10,2) NOT NULL DEFAULT 0.00,
  `kami` text NOT NULL,
  `configure1` text NOT NULL,
  `addons` text NOT NULL,
  `isdelete` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_payment` (
  `id` int NOT NULL AUTO_INCREMENT,
  `payment` varchar(55) DEFAULT '',
  `payname` varchar(55) NOT NULL DEFAULT '',
  `payimage` varchar(255) NOT NULL DEFAULT '',
  `alias` varchar(55) NOT NULL DEFAULT '',
  `sign_type` enum('RSA','RSA2','MD5','HMAC-SHA256') NOT NULL DEFAULT 'RSA2',
  `app_id` varchar(255) NOT NULL DEFAULT '',
  `app_secret` varchar(255) NOT NULL DEFAULT '',
  `ali_public_key` text NOT NULL,
  `rsa_private_key` text NOT NULL,
  `configure3` text NOT NULL,
  `configure4` text NOT NULL,
  `overtime` int NOT NULL DEFAULT 0,
  `active` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_products` (
  `id` int NOT NULL AUTO_INCREMENT,
  `typeid` int NOT NULL DEFAULT 1,
  `active` tinyint(1) NOT NULL DEFAULT 0,
  `name` varchar(255) NOT NULL DEFAULT '',
  `password` varchar(60) NOT NULL DEFAULT '',
  `description` text NOT NULL,
  `stockcontrol` tinyint(1) NOT NULL DEFAULT 0,
  `qty` int NOT NULL DEFAULT 0,
  `qty_virtual` int NOT NULL DEFAULT 0,
  `qty_switch` tinyint(1) NOT NULL DEFAULT 0,
  `qty_sell` int NOT NULL DEFAULT 0,
  `price` decimal(10,2) NOT NULL DEFAULT 0.00,
  `price_ori` decimal(10,2) NOT NULL DEFAULT 0.00,
  `auto` tinyint(1) NOT NULL DEFAULT 0,
  `addons` text NOT NULL,
  `sort_num` int NOT NULL DEFAULT 1,
  `addtime` int NOT NULL DEFAULT 0,
  `isdelete` tinyint(1) NOT NULL DEFAULT 0,
  `imgurl` text NOT NULL,
  `iszhekou` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_products_card` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pid` int NOT NULL DEFAULT 0,
  `card` text NOT NULL,
  `addtime` int NOT NULL DEFAULT 0,
  `active` tinyint(1) NOT NULL DEFAULT 0,
  `isdelete` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_products_pifa` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pid` int NOT NULL DEFAULT 0,
  `qty` int NOT NULL DEFAULT 0,
  `discount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `tag` varchar(255) NOT NULL DEFAULT '',
  `addtime` int NOT NULL DEFAULT 0,
  `isdelete` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_products_type` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(55) NOT NULL DEFAULT '',
  `description` varchar(255) NOT NULL DEFAULT '',
  `password` varchar(60) NOT NULL DEFAULT '',
  `sort_num` int NOT NULL DEFAULT 1,
  `active` tinyint(1) NOT NULL DEFAULT 0,
  `isdelete` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_seo` (
  `id` int NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_ticket` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userid` int NOT NULL DEFAULT 0,
  `typeid` int NOT NULL DEFAULT 1,
  `priority` tinyint(1) NOT NULL DEFAULT 0,
  `subject` varchar(255) NOT NULL DEFAULT '',
  `content` text NOT NULL,
  `status` tinyint NOT NULL DEFAULT 0,
  `addtime` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `groupid` int NOT NULL DEFAULT 1,
  `nickname` varchar(255) NOT NULL DEFAULT '',
  `password` varchar(255) NOT NULL DEFAULT '',
  `email` varchar(255) NOT NULL DEFAULT '',
  `qq` varchar(20) NOT NULL DEFAULT '',
  `mobilephone` varchar(15) NOT NULL DEFAULT '',
  `money` decimal(10,2) NOT NULL DEFAULT 0.00,
  `integral` int NOT NULL DEFAULT 0,
  `tag` varchar(255) NOT NULL DEFAULT '',
  `createtime` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_user_group` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL DEFAULT '',
  `remark` varchar(100) NOT NULL DEFAULT '',
  `discount` decimal(10,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_user_login_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userid` int NOT NULL DEFAULT 0,
  `ip` varchar(25) NOT NULL DEFAULT '',
  `addtime` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `t_article` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `content` longtext NOT NULL,
  `excerpt` text,
  `slug` varchar(255) DEFAULT NULL,
  `status` tinyint(1) DEFAULT 1,
  `views` int DEFAULT 0,
  `keywords` varchar(255) DEFAULT NULL,
  `description` varchar(500) DEFAULT NULL,
  `sort` int DEFAULT 0,
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_slug` (`slug`),
  KEY `idx_sort` (`sort`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `t_config_cat` (`id`, `catname`, `catkey`) VALUES
  (1, '基础设置', 'basic'), (2, '其他设置', 'other');

INSERT INTO `t_user_group` (`id`, `name`, `remark`, `discount`) VALUES
  (1, '普通', '普通用户', 0.00),
  (2, 'VIP1', 'VIP1用户', 0.00),
  (3, 'VIP2', 'VIP2用户', 0.00),
  (4, 'VIP3', 'VIP3用户', 0.00);

INSERT INTO `t_config` (`id`, `catid`, `name`, `value`, `tag`, `lock`, `updatetime`) VALUES
  (1, 1, 'registerswitch', '1', '是否开放注册功能,1是开放,0是关闭', 1, 1453452674),
  (2, 1, 'limitiporder', '0', '同一ip当日下单限制（针对未付款订单）,不限制请设置为0', 1, 1453452674),
  (3, 1, 'limitemailorder', '0', '同一email当日下单限制（针对未付款订单）,不限制请设置为0', 1, 1453452674),
  (4, 1, 'weburl', '', '当前网站地址,用于支付站点异步返回，务必修改正确', 1, 1453452674),
  (5, 1, 'adminemail', 'demo@demo.com', '管理员邮箱,用于接收邮件提醒用', 1, 1453452674),
  (6, 1, 'webname', 'ZFAKA平台', '当前站点名称', 1, 1453452674),
  (7, 1, 'webdescription', '本系统由资料空白开发并免费提供', '当前站点描述', 1, 1453452674),
  (8, 1, 'notice', '', '首页公告', 1, 1453452674),
  (9, 1, 'ad', '', '购买页默认内容', 1, 1453452674),
  (10, 1, 'yzmswitch', '0', '验证码开关(1开，0关)', 1, 1453452674),
  (11, 1, 'orderinputtype', '1', '订单必填输入框选择: 1邮箱 2QQ', 1, 1453452674),
  (12, 1, 'logo', '/res/images/logo.png', 'LOGO地址,默认：/res/images/logo.png', 1, 1453452674),
  (13, 1, 'tongji', '<!--统计js-->', '统计脚本', 1, 1453452674),
  (14, 1, 'mprodcutdescriptionswitch', '0', '移动端商品详情，隐藏(0)|显示(1)', 1, 1453452674),
  (15, 1, 'orderprefix', 'flox', '订单前缀，只能是英文和数字,且长度不要超过5个字符串', 1, 1453452674),
  (16, 1, 'backgroundimage', '', '前台背景图片地址', 1, 1453452674),
  (17, 1, 'headermenucolor', 'layui-bg-black', '前台顶部菜单配色方案', 1, 1453452674),
  (18, 1, 'layerad', '', '弹窗广告', 1, 1453452674),
  (19, 1, 'loginswitch', '1', '登录开关', 1, 1453452674),
  (20, 1, 'forgetpwdswitch', '0', '找回密码开关', 1, 1453452674),
  (21, 1, 'adminyzmswitch', '0', '后台登录验证码开关', 1, 1453452674),
  (22, 1, 'shortcuticon', '/res/images/favicon.ico', 'ICO图标,格式必须是png或者ico或者gif', 1, 1453452674),
  (23, 1, 'limitorderqty', '5', '单笔订单数量限制', 1, 1453452674),
  (24, 1, 'discountswitch', '0', '折扣开关', 1, 1453452674),
  (25, 1, 'qrserver', '/product/order/showqr/?url=', '生成二维码的服务地址', 1, 1453452674),
  (26, 1, 'paysubjectswitch', '0', '订单说明显示:0商品名,1订单号,或者自定义', 1, 1453452674),
  (27, 1, 'emailswitch', '1', '发送用户邮件开关', 1, 1546063186),
  (28, 1, 'emailsendtypeswitch', '1', '发送用户邮件方式筛选开关', 1, 1546063186),
  (29, 1, 'querycontactswitch', '1', '查询方式(联系方式)开关', 1, 1546063186),
  (30, 1, 'tpl', 'tokyo', '全新的整站模版', 1, 1546063186);

INSERT INTO `t_payment` (`id`, `payment`, `payname`, `payimage`, `alias`, `sign_type`, `app_id`, `app_secret`, `ali_public_key`, `rsa_private_key`, `configure3`, `configure4`, `overtime`, `active`) VALUES
  (1, '支付宝当面付', '支付宝', '/res/images/pay/alipay.jpg', 'zfbf2f', 'RSA2', '', '', '', '', '', '', 0, 0),
  (2, '支付宝电脑网站支付(WEB)', '支付宝', '/res/images/pay/alipay.jpg', 'zfbweb', 'RSA2', '', '', '', '', '', '', 0, 0),
  (3, '微信扫码支付', '微信', '/res/images/pay/weixin.jpg', 'wxf2f', 'MD5', '', '', '', '', '', '', 0, 0),
  (4, '微信H5支付', '微信', '/res/images/pay/weixin.jpg', 'wxh5', 'MD5', '', '', '', '', '', '', 0, 0),
  (5, 'PAYPAL', 'PAYPAL', '/res/images/pay/paypal.jpg', 'paypal', 'RSA2', '', '', '', '', 'live', '7', 0, 0),
  (6, 'V免签微信', '微信', '/res/images/pay/weixin.jpg', 'vpaywx', 'MD5', '', '', '', '', '', '', 0, 0),
  (7, 'V免签支付宝', '支付宝', '/res/images/pay/alipay.jpg', 'vpayalipay', 'MD5', '', '', '', '', '', '', 0, 0),
  (8, 'U支付', 'USDT', '/res/images/pay/usdt.jpg', 'uzhifu', 'MD5', '', '', '', '', '', '', 6000, 0),
  (9, '易支付', '易支付', '/res/images/pay/yipay.jpg', 'yipay', 'MD5', '', '', '', '', '', 'epay', 600, 0),
  (10, 'GMPay USDT', 'USDT', '/res/images/pay/gmpay.jpg', 'gmpay', 'MD5', '', '', '', '', '', 'tron', 600, 0);
