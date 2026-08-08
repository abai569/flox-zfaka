CREATE TABLE IF NOT EXISTS `t_products_image` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pid` int NOT NULL DEFAULT 0,
  `imgurl` varchar(500) NOT NULL DEFAULT '',
  `is_primary` tinyint(1) NOT NULL DEFAULT 0,
  `sort_num` int NOT NULL DEFAULT 0,
  `addtime` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_products_image_pid` (`pid`),
  KEY `idx_products_image_primary` (`pid`,`is_primary`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `t_products_image` (`pid`, `imgurl`, `is_primary`, `sort_num`, `addtime`)
SELECT `id`, `imgurl`, 1, 0, UNIX_TIMESTAMP()
FROM `t_products`
WHERE `imgurl` <> ''
  AND NOT EXISTS (
    SELECT 1 FROM `t_products_image` WHERE `t_products_image`.`pid` = `t_products`.`id`
  );
