SET @admin_region_sql = IF(
  EXISTS(
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 't_admin_login_log'
      AND COLUMN_NAME = 'region'
  ),
  'SELECT 1',
  'ALTER TABLE `t_admin_login_log` ADD COLUMN `region` varchar(255) NOT NULL DEFAULT '''' COMMENT ''登录地区'' AFTER `ip`'
);
PREPARE admin_region_statement FROM @admin_region_sql;
EXECUTE admin_region_statement;
DEALLOCATE PREPARE admin_region_statement;

ALTER TABLE `t_admin_login_log`
  MODIFY COLUMN `ip` varchar(45) NOT NULL DEFAULT '' COMMENT '登录ip';

SET @user_region_sql = IF(
  EXISTS(
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 't_user_login_logs'
      AND COLUMN_NAME = 'region'
  ),
  'SELECT 1',
  'ALTER TABLE `t_user_login_logs` ADD COLUMN `region` varchar(255) NOT NULL DEFAULT '''' COMMENT ''登录地区'' AFTER `ip`'
);
PREPARE user_region_statement FROM @user_region_sql;
EXECUTE user_region_statement;
DEALLOCATE PREPARE user_region_statement;

ALTER TABLE `t_user_login_logs`
  MODIFY COLUMN `ip` varchar(45) NOT NULL DEFAULT '' COMMENT '登录ip';
