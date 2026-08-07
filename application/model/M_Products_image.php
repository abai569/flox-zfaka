<?php

class M_Products_image extends Model
{
    public function __construct()
    {
        $this->table = TB_PREFIX.'products_image';
        parent::__construct();
    }

    public function getByProduct($pid)
    {
        return $this->Where(array('pid'=>$pid))
            ->Order(array('sort_num'=>'DESC', 'id'=>'ASC'))
            ->Select();
    }
}
