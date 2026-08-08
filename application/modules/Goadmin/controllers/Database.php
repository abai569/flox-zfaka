<?php

class DatabaseController extends AdminBasicController
{
	private $backupPath;

	public function init()
	{
		parent::init();
		$this->backupPath = rtrim(TEMP_PATH, '/\\') . '/database-backups';
	}

	public function indexAction()
	{
		if (!$this->isLoggedIn()) {
			return FALSE;
		}

		if (!is_dir($this->backupPath)) {
			@mkdir($this->backupPath, 0750, true);
		}

		$backups = array();
		foreach (glob($this->backupPath . '/*.sql') ?: array() as $file) {
			$backups[] = array(
				'name' => basename($file),
				'size' => $this->formatBytes(filesize($file)),
				'time' => date('Y-m-d H:i:s', filemtime($file)),
			);
		}
		usort($backups, function ($left, $right) {
			return strcmp($right['name'], $left['name']);
		});

		$message = $this->getSession('database_message');
		$this->unsetSession('database_message');
		$this->getView()->assign(array('backups' => $backups, 'database_message' => $message));
	}

	public function exportAction()
	{
		if (!$this->isLoggedIn() || !$this->VerifyCsrfToken($this->getPost('csrf_token', false))) {
			$this->redirect('/' . ADMIN_DIR . '/database');
			return FALSE;
		}

		$file = $this->backupPath . '/zfaka-export-' . date('Ymd-His') . '.sql';
		if (!$this->createBackup($file)) {
			$this->redirectWithMessage(1000, '数据库导出失败');
			return FALSE;
		}

		$this->sendFile($file, true);
		return FALSE;
	}

	public function importAction()
	{
		if (!$this->isLoggedIn() || !$this->VerifyCsrfToken($this->getPost('csrf_token', false))) {
			$this->redirect('/' . ADMIN_DIR . '/database');
			return FALSE;
		}

		if (!isset($_FILES['sql_file']) || $_FILES['sql_file']['error'] !== UPLOAD_ERR_OK || !is_uploaded_file($_FILES['sql_file']['tmp_name'])) {
			$this->redirectWithMessage(1000, '请选择有效的 SQL 文件');
			return FALSE;
		}

		$upload = $_FILES['sql_file'];
		if (strtolower(pathinfo($upload['name'], PATHINFO_EXTENSION)) !== 'sql' || $upload['size'] <= 0 || $upload['size'] > 67108864) {
			$this->redirectWithMessage(1000, '仅支持不超过 64 MB 的 SQL 文件');
			return FALSE;
		}

		$sql = file_get_contents($upload['tmp_name']);
		if ($sql === false || strpos($sql, 't_config') === false || preg_match('/^\s*(?:\\!|system\s|source\s|tee\s|pager\s)/mi', $sql)) {
			$this->redirectWithMessage(1000, 'SQL 文件不是有效的 ZFAKA 数据备份');
			return FALSE;
		}

		$backup = $this->backupPath . '/before-import-' . date('Ymd-His') . '.sql';
		if (!$this->createBackup($backup)) {
			$this->redirectWithMessage(1000, '导入前自动备份失败，已取消导入');
			return FALSE;
		}

		if (!$this->runMysql($upload['tmp_name'])) {
			$restored = $this->runMysql($backup);
			$this->clearCaches();
			$this->redirectWithMessage(1000, $restored ? '数据库导入失败，已恢复导入前备份' : '数据库导入失败，自动恢复也失败，请使用备份文件手动恢复');
			return FALSE;
		}

		$this->clearCaches();
		$this->redirectWithMessage(1, '数据库导入成功');
		return FALSE;
	}

	public function downloadAction()
	{
		if (!$this->isLoggedIn()) {
			return FALSE;
		}

		$name = basename($this->get('file', false));
		if (!preg_match('/^(?:before-import|zfaka-export)-\d{8}-\d{6}\.sql$/', $name)) {
			$this->redirect('/' . ADMIN_DIR . '/database');
			return FALSE;
		}

		$file = $this->backupPath . '/' . $name;
		if (!is_file($file)) {
			$this->redirect('/' . ADMIN_DIR . '/database');
			return FALSE;
		}

		$this->sendFile($file, false);
		return FALSE;
	}

	private function isLoggedIn()
	{
		if ($this->AdminUser == FALSE || empty($this->AdminUser)) {
			$this->redirect('/' . ADMIN_DIR . '/login');
			return false;
		}
		return true;
	}

	private function createBackup($file)
	{
		if (!function_exists('proc_open')) {
			return false;
		}
		if (!is_dir($this->backupPath) && !@mkdir($this->backupPath, 0750, true)) {
			return false;
		}

		$config = $this->databaseConfig();
		$command = array(
			'mysqldump', '--single-transaction', '--triggers', '--add-drop-table',
			'-h', $config['host'], '-P', $config['port'], '-u', $config['user'], $config['name'],
		);
		$descriptors = array(1 => array('file', $file, 'w'), 2 => array('pipe', 'w'));
		$process = proc_open($command, $descriptors, $pipes, null, $this->commandEnvironment($config['password']));
		if (!is_resource($process)) {
			return false;
		}
		stream_get_contents($pipes[2]);
		fclose($pipes[2]);
		$success = proc_close($process) === 0 && is_file($file) && filesize($file) > 0;
		if (!$success) {
			@unlink($file);
		}
		return $success;
	}

	private function runMysql($file)
	{
		if (!function_exists('proc_open')) {
			return false;
		}
		$config = $this->databaseConfig();
		$command = array('mysql', '-h', $config['host'], '-P', $config['port'], '-u', $config['user'], $config['name']);
		$descriptors = array(0 => array('file', $file, 'r'), 1 => array('pipe', 'w'), 2 => array('pipe', 'w'));
		$process = proc_open($command, $descriptors, $pipes, null, $this->commandEnvironment($config['password']));
		if (!is_resource($process)) {
			return false;
		}
		stream_get_contents($pipes[1]);
		stream_get_contents($pipes[2]);
		fclose($pipes[1]);
		fclose($pipes[2]);
		return proc_close($process) === 0;
	}

	private function databaseConfig()
	{
		$config = Yaf\Application::app()->getConfig();
		return array(
			'host' => getenv('DB_HOST') ?: (string) $config['WRITE_HOST'],
			'port' => getenv('DB_PORT') ?: (string) ($config['WRITE_PORT'] ?: 3306),
			'user' => getenv('DB_USER') ?: (string) $config['WRITE_USER'],
			'password' => getenv('DB_PASSWORD') ?: (string) $config['WRITE_PSWD'],
			'name' => getenv('DB_NAME') ?: (string) $config['Default'],
		);
	}

	private function commandEnvironment($password)
	{
		return array('MYSQL_PWD' => $password, 'PATH' => getenv('PATH'));
	}

	private function clearCaches()
	{
		@unlink(TEMP_PATH . '/config.json');
		@unlink(TEMP_PATH . '/payment.json');
	}

	private function redirectWithMessage($code, $message)
	{
		$this->setSession('database_message', array('code' => $code, 'text' => $message));
		$this->redirect('/' . ADMIN_DIR . '/database');
	}

	private function sendFile($file, $deleteAfter)
	{
		header('Content-Type: application/sql');
		header('Content-Disposition: attachment; filename="' . basename($file) . '"');
		header('Content-Length: ' . filesize($file));
		header('Cache-Control: no-store');
		readfile($file);
		if ($deleteAfter) {
			@unlink($file);
		}
		exit();
	}

	private function formatBytes($bytes)
	{
		if ($bytes >= 1048576) {
			return number_format($bytes / 1048576, 2) . ' MB';
		}
		return number_format($bytes / 1024, 2) . ' KB';
	}
}
