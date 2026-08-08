<?php

/*
 * 功能：后台中心－Docker 升级入口
 * 作者: Flox ZFAKA
 */

class UpgradeController extends AdminBasicController
{
    private $project_url = 'https://github.com/abai569/flox-zfaka';

    public function init()
    {
        parent::init();
    }

    public function indexAction()
    {
        if ($this->AdminUser == FALSE AND empty($this->AdminUser)) {
            $this->redirect('/' . ADMIN_DIR . '/login');
            return FALSE;
        }

        $this->redirect($this->project_url . '/tags');
        return FALSE;
    }

    public function getremotefileAction()
    {
        if ($this->AdminUser == FALSE AND empty($this->AdminUser)) {
            Helper::response(array('code' => 1000, 'msg' => '请登录'));
        }

        Helper::response(array(
            'code' => 1001,
            'msg' => 'Docker 版本请在服务器执行 bash install.sh update',
        ));
    }
}
