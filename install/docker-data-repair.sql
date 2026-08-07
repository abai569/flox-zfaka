SET NAMES utf8mb4;
START TRANSACTION;

CREATE TEMPORARY TABLE `_zfaka_config_old` AS SELECT * FROM `t_config`;
DELETE FROM `t_config`;

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

UPDATE `t_config` AS current
JOIN `_zfaka_config_old` AS old ON old.`name` = current.`name`
SET current.`value` = old.`value`, current.`tag` = old.`tag`, current.`lock` = old.`lock`, current.`updatetime` = old.`updatetime`;

INSERT INTO `t_config` (`catid`, `name`, `value`, `tag`, `lock`, `updatetime`)
SELECT old.`catid`, old.`name`, old.`value`, old.`tag`, old.`lock`, old.`updatetime`
FROM `_zfaka_config_old` AS old
LEFT JOIN `t_config` AS current ON current.`name` = old.`name`
WHERE current.`id` IS NULL;

CREATE TEMPORARY TABLE `_zfaka_payment_old` AS SELECT * FROM `t_payment`;
DELETE FROM `t_payment`;

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

UPDATE `t_payment` AS current
JOIN `_zfaka_payment_old` AS old ON old.`alias` = current.`alias`
SET current.`payment` = old.`payment`, current.`payname` = old.`payname`, current.`payimage` = old.`payimage`,
    current.`sign_type` = old.`sign_type`, current.`app_id` = old.`app_id`, current.`app_secret` = old.`app_secret`,
    current.`ali_public_key` = old.`ali_public_key`, current.`rsa_private_key` = old.`rsa_private_key`,
    current.`configure3` = old.`configure3`, current.`configure4` = old.`configure4`,
    current.`overtime` = old.`overtime`, current.`active` = old.`active`;

INSERT INTO `t_payment` (`payment`, `payname`, `payimage`, `alias`, `sign_type`, `app_id`, `app_secret`, `ali_public_key`, `rsa_private_key`, `configure3`, `configure4`, `overtime`, `active`)
SELECT old.`payment`, old.`payname`, old.`payimage`, old.`alias`, old.`sign_type`, old.`app_id`, old.`app_secret`,
       old.`ali_public_key`, old.`rsa_private_key`, old.`configure3`, old.`configure4`, old.`overtime`, old.`active`
FROM `_zfaka_payment_old` AS old
LEFT JOIN `t_payment` AS current ON current.`alias` = old.`alias`
WHERE current.`id` IS NULL;

COMMIT;
