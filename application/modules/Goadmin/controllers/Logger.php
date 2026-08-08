<?php

/*
 * 功能：后台管理－登录日志
 * Author:资料空白
 * Date:20150902
 */

class LoggerController extends AdminBasicController
{
	private $m_admin_login_log;
    public function init()
    {
        parent::init();
		$this->m_admin_login_log = $this->load('admin_login_log');
    }

    public function indexAction()
    {
        if ($this->AdminUser==FALSE AND empty($this->AdminUser)) {
            $this->redirect('/'.ADMIN_DIR.'/login');
            return FALSE;
        }
		$data = array();
		$data['title'] = "登录日志";
        $this->getView()->assign($data);
    }

	
	//登录日志ajax
	public function ajaxAction()
	{
        if ($this->AdminUser==FALSE AND empty($this->AdminUser)) {
            $data = array('code' => 1000, 'msg' => '请登录');
			Helper::response($data);
        }
		
		$page = $this->get('page');
		$page = max(1, is_numeric($page) ? (int)$page : 1);
		
		$limit = $this->get('limit');
		$limit = min(100, max(1, is_numeric($limit) ? (int)$limit : 10));
		
		$total=$this->m_admin_login_log->Total();
		
        if ($total > 0) {
            if ($page > 0 && $page < (ceil($total / $limit) + 1)) {
                $pagenum = ($page - 1) * $limit;
            } else {
                $pagenum = 0;
            }
			
            $limits = "{$pagenum},{$limit}";
			$items=$this->m_admin_login_log->Limit($limits)->Order(array('id'=>'DESC'))->Select();
			
            if (empty($items)) {
                $data = array('code'=>0,'count'=>0,'data'=>array(),'msg'=>'无数据');
            } else {
                $data = array('code'=>0,'count'=>$total,'data'=>$items,'msg'=>'有数据');
            }
        } else {
            $data = array('code'=>0,'count'=>0,'data'=>array(),'msg'=>'无数据');
        }
		Helper::response($data);
	}
}
