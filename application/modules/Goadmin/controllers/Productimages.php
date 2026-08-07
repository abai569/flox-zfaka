<?php

class ProductimagesController extends AdminBasicController
{
    private $m_products;
    private $m_products_image;

    public function init()
    {
        parent::init();
        $this->m_products = $this->load('products');
        $this->m_products_image = $this->load('products_image');
        Yaf\Dispatcher::getInstance()->disableView();
    }

    public function uploadAction()
    {
        if (!$this->authorized()) return;

        $pid = $this->getPost('pid');
        if (!$this->validRequest($pid) || !$this->productExists($pid) || !isset($_FILES['file']) || !is_array($_FILES['file'])) {
            Helper::response(array('code'=>1000, 'msg'=>'上传参数错误'));
        }

        $images = $this->m_products_image->Where(array('pid'=>$pid))->Select();
        if (count($images) >= 10) {
            Helper::response(array('code'=>1001, 'msg'=>'每个商品最多上传10张图片'));
        }

        $file = $_FILES['file'];
        if (!isset($file['error'], $file['size'], $file['tmp_name']) || $file['error'] !== UPLOAD_ERR_OK) {
            Helper::response(array('code'=>1002, 'msg'=>'图片上传失败'));
        }
        if ($file['size'] <= 0 || $file['size'] > 5 * 1024 * 1024) {
            Helper::response(array('code'=>1003, 'msg'=>'单张图片不能超过5MB'));
        }

        $imageInfo = @getimagesize($file['tmp_name']);
        $types = array(IMAGETYPE_JPEG=>'jpg', IMAGETYPE_PNG=>'png', IMAGETYPE_GIF=>'gif', IMAGETYPE_WEBP=>'webp');
        if (!$imageInfo || !isset($types[$imageInfo[2]])) {
            Helper::response(array('code'=>1004, 'msg'=>'仅支持 JPG、PNG、GIF 和 WebP 图片'));
        }

        $targetPath = rtrim(UPLOAD_PATH, '/').'/'.CUR_DATE;
        if (!is_dir($targetPath) && !mkdir($targetPath, 0755, true)) {
            Helper::response(array('code'=>1005, 'msg'=>'无法创建图片目录'));
        }

        $fileName = date('His').'_'.bin2hex(random_bytes(4)).'.'.$types[$imageInfo[2]];
        $targetFile = $targetPath.'/'.$fileName;
        if (!move_uploaded_file($file['tmp_name'], $targetFile)) {
            Helper::response(array('code'=>1006, 'msg'=>'无法保存图片'));
        }

        $isPrimary = empty($images) ? 1 : 0;
        $sortNum = 0;
        foreach ($images as $image) {
            $sortNum = max($sortNum, (int)$image['sort_num'] + 1);
        }
        $imgurl = '/res/upload/'.CUR_DATE.'/'.$fileName;
        $imageId = $this->m_products_image->Insert(array(
            'pid'=>$pid,
            'imgurl'=>$imgurl,
            'is_primary'=>$isPrimary,
            'sort_num'=>$sortNum,
            'addtime'=>time(),
        ));
        if (!$imageId) {
            @unlink($targetFile);
            Helper::response(array('code'=>1007, 'msg'=>'无法保存图片记录'));
        }
        if ($isPrimary) {
            $this->m_products->UpdateByID(array('imgurl'=>$imgurl), $pid);
        }

        Helper::response(array('code'=>1, 'msg'=>'上传成功'));
    }

    public function primaryAction()
    {
        if (!$this->authorized()) return;
        $pid = $this->getPost('pid');
        $id = $this->getPost('id');
        if (!$this->validRequest($pid) || !$this->productExists($pid) || !is_numeric($id)) {
            Helper::response(array('code'=>1000, 'msg'=>'参数错误'));
        }

        $image = $this->m_products_image->Where(array('id'=>$id, 'pid'=>$pid))->SelectOne();
        if (!$image) {
            Helper::response(array('code'=>1001, 'msg'=>'图片不存在'));
        }
        $this->m_products_image->Where(array('pid'=>$pid))->Update(array('is_primary'=>0));
        $this->m_products_image->UpdateByID(array('is_primary'=>1), $id);
        $this->m_products->UpdateByID(array('imgurl'=>$image['imgurl']), $pid);
        Helper::response(array('code'=>1, 'msg'=>'主图已更新'));
    }

    public function deleteAction()
    {
        if (!$this->authorized()) return;
        $pid = $this->getPost('pid');
        $id = $this->getPost('id');
        if (!$this->validRequest($pid) || !$this->productExists($pid) || !is_numeric($id)) {
            Helper::response(array('code'=>1000, 'msg'=>'参数错误'));
        }

        $image = $this->m_products_image->Where(array('id'=>$id, 'pid'=>$pid))->SelectOne();
        if (!$image) {
            Helper::response(array('code'=>1001, 'msg'=>'图片不存在'));
        }
        $this->m_products_image->DeleteByID($id);
        $path = APP_PATH.'/public'.$image['imgurl'];
        $uploadRoot = realpath(UPLOAD_PATH);
        $imageDirectory = realpath(dirname($path));
        if ($uploadRoot && $imageDirectory && strpos($imageDirectory.DIRECTORY_SEPARATOR, rtrim($uploadRoot, DIRECTORY_SEPARATOR).DIRECTORY_SEPARATOR) === 0 && is_file($path)) {
            @unlink($path);
        }

        if ((int)$image['is_primary'] === 1) {
            $next = $this->m_products_image->Where(array('pid'=>$pid))->Order(array('sort_num'=>'DESC', 'id'=>'ASC'))->SelectOne();
            $nextUrl = '';
            if ($next) {
                $this->m_products_image->UpdateByID(array('is_primary'=>1), $next['id']);
                $nextUrl = $next['imgurl'];
            }
            $this->m_products->UpdateByID(array('imgurl'=>$nextUrl), $pid);
        }
        Helper::response(array('code'=>1, 'msg'=>'图片已删除'));
    }

    public function moveAction()
    {
        if (!$this->authorized()) return;
        $pid = $this->getPost('pid');
        $id = $this->getPost('id');
        $direction = $this->getPost('direction', false);
        if (!$this->validRequest($pid) || !$this->productExists($pid) || !is_numeric($id) || !in_array($direction, array('before', 'after'))) {
            Helper::response(array('code'=>1000, 'msg'=>'参数错误'));
        }

        $images = $this->m_products_image->getByProduct($pid);
        $position = null;
        foreach ($images as $index=>$image) {
            if ((int)$image['id'] === (int)$id) $position = $index;
        }
        $swap = $direction === 'before' ? $position - 1 : $position + 1;
        if ($position === null || !isset($images[$swap])) {
            Helper::response(array('code'=>1001, 'msg'=>'图片已在边界位置'));
        }

        $currentSort = $images[$position]['sort_num'];
        $this->m_products_image->UpdateByID(array('sort_num'=>$images[$swap]['sort_num']), $images[$position]['id']);
        $this->m_products_image->UpdateByID(array('sort_num'=>$currentSort), $images[$swap]['id']);
        Helper::response(array('code'=>1, 'msg'=>'排序已更新'));
    }

    private function authorized()
    {
        if ($this->AdminUser == FALSE AND empty($this->AdminUser)) {
            Helper::response(array('code'=>1000, 'msg'=>'请登录'));
            return false;
        }
        return true;
    }

    private function validRequest($pid)
    {
        return is_numeric($pid) && $pid > 0 && $this->VerifyCsrfToken($this->getPost('csrf_token', false));
    }

    private function productExists($pid)
    {
        return (bool)$this->m_products->Where(array('id'=>$pid, 'isdelete'=>0))->SelectOne();
    }
}
