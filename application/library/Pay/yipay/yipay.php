<?php
namespace Pay\yipay;
use \Pay\notify;

class yipay
{
    private $paymethod = "yipay";

    public function pay($payconfig, $params)
    {
        try {
            $gateway = rtrim($payconfig['configure3'], '/');
            $pid = $payconfig['app_id'];
            $key = $payconfig['app_secret'];
            $paytype = isset($params['paytype']) ? $params['paytype'] : 'alipay';
            $signMode = !empty($payconfig['configure4']) ? $payconfig['configure4'] : 'epay';

            $notifyUrl = $params['weburl'] . '/product/notify/?paymethod=' . $this->paymethod;
            $returnUrl = $params['weburl'] . '/query/auto/' . $params['orderid'] . '.html';

            $data = array(
                'pid' => $pid,
                'type' => $paytype,
                'out_trade_no' => $params['orderid'],
                'notify_url' => $notifyUrl,
                'return_url' => $returnUrl,
                'name' => $params['productname'],
                'money' => sprintf("%.2f", $params['money']),
            );

            $sign = $this->epaySign($data, $key, $signMode);
            $data['sign'] = $sign;
            $data['sign_type'] = 'MD5';

            $payUrl = $gateway . '/submit.php?' . http_build_query($data);

            $result = array(
                'type' => 1,
                'paymethod' => $this->paymethod,
                'payname' => '易支付',
                'url' => $payUrl,
                'overtime' => $payconfig['overtime'],
                'money' => $params['money'],
            );
            return array('code' => 1, 'msg' => 'success', 'data' => $result);
        } catch (\Exception $e) {
            return array('code' => 1000, 'msg' => $e->getMessage(), 'data' => '');
        }
    }

    public function notify($payconfig)
    {
        if (!$_POST) {
            return 'error|no post data';
        }

        $key = $payconfig['app_secret'];
        $signMode = !empty($payconfig['configure4']) ? $payconfig['configure4'] : 'epay';

        $sign = isset($_POST['sign']) ? $_POST['sign'] : '';

        $params = $_POST;
        unset($params['sign']);
        unset($params['sign_type']);

        $calculatedSign = $this->epaySign($params, $key, $signMode);
        if ($calculatedSign !== $sign) {
            return 'error|sign mismatch';
        }

        if (!isset($_POST['trade_status']) || $_POST['trade_status'] != 'TRADE_SUCCESS') {
            return 'error|trade not success';
        }

        $config = array(
            'paymethod' => $this->paymethod,
            'tradeid' => isset($_POST['trade_no']) ? $_POST['trade_no'] : $_POST['out_trade_no'],
            'paymoney' => isset($_POST['money']) ? $_POST['money'] : 0,
            'orderid' => isset($_POST['out_trade_no']) ? $_POST['out_trade_no'] : '',
        );
        $notify = new \Pay\notify();
        $data = $notify->run($config);

        if ($data['code'] > 1) {
            return 'error|' . $data['msg'];
        }
        return 'success';
    }

    private function epaySign($params, $key, $signMode = 'epay')
    {
        ksort($params);
        $buf = '';
        foreach ($params as $k => $v) {
            if ($v === '' || $v === null) {
                continue;
            }
            $buf .= $k . '=' . $v . '&';
        }

        if ($signMode === 'mpay') {
            $buf = rtrim($buf, '&');
            $buf .= $key;
        } else {
            $buf .= 'key=' . $key;
        }

        return md5($buf);
    }
}
