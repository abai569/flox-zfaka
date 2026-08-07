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

INSERT INTO `t_config` (`catid`, `name`, `value`, `tag`, `lock`, `updatetime`) VALUES
  (1, 'registerswitch', '1', '是否开放注册功能', 1, 0),
  (1, 'weburl', '', '当前站点地址', 1, 0),
  (1, 'webname', 'ZFAKA平台', '当前站点名称', 1, 0),
  (1, 'webdescription', '本系统由资料空白开发并免费提供', '当前站点描述', 1, 0),
  (1, 'yzmswitch', '0', '验证码开关', 1, 0),
  (1, 'orderinputtype', '1', '订单输入类型', 1, 0),
  (1, 'tpl', 'tokyo', '全新的整站模版', 1, 0),
  (1, 'querycontactswitch', '1', '安全密码查询开关', 1, 0),
  (1, 'loginswitch', '1', '登录开关', 1, 0),
  (1, 'forgetpwdswitch', '0', '找回密码开关', 1, 0),
  (1, 'adminyzmswitch', '0', '后台登录验证码开关', 1, 0),
  (1, 'orderprefix', 'flox', '订单前缀', 1, 0),
  (1, 'limitorderqty', '5', '单笔订单数量限制', 1, 0),
  (1, 'discountswitch', '0', '折扣开关', 1, 0),
  (1, 'emailswitch', '0', '发送用户邮件开关', 1, 0),
  (1, 'emailsendtypeswitch', '0', '发送邮件方式筛选开关', 1, 0);
