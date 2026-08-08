<?php
namespace Pay\gmpay;
use \Pay\notify;

class gmpay
{
    private $paymethod = "gmpay";

    public function pay($payconfig, $params)
    {
        try {
            $apiUrl = rtrim($payconfig['configure3'], '/');
            $pid = $payconfig['app_id'];
            $secretKey = $payconfig['app_secret'];
            $network = !empty($payconfig['configure4']) ? $payconfig['configure4'] : 'tron';

            $notifyUrl = $params['weburl'] . '/product/notify/?paymethod=' . $this->paymethod;

            $orderNo = $params['orderid'];
            $amount = $params['money'];

            $signParams = array(
                'pid' => $pid,
                'order_id' => $orderNo,
                'currency' => 'cny',
                'token' => 'usdt',
                'network' => $network,
                'amount' => rtrim(rtrim(sprintf("%.10f", $amount), '0'), '.'),
                'notify_url' => $notifyUrl,
            );

            $signature = $this->gmpaySign($signParams, $secretKey);

            $postData = $signParams;
            $postData['amount'] = (float)$amount;
            $postData['signature'] = $signature;

            $endpoint = $apiUrl . '/payments/gmpay/v1/order/create-transaction';

            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, $endpoint);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
            curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 10);
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
            curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
            curl_setopt($ch, CURLOPT_POST, 1);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($postData));
            curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);

            if (!$response) {
                return array('code' => 1002, 'msg' => '请求支付网关失败', 'data' => '');
            }

            if ($httpCode != 200) {
                return array('code' => 1002, 'msg' => '支付网关返回异常：HTTP ' . $httpCode, 'data' => $response);
            }

            $result = json_decode($response, true);
            if (!$result) {
                return array('code' => 1002, 'msg' => '支付网关返回异常：无效响应', 'data' => $response);
            }

            $code = isset($result['code']) ? $result['code'] : (isset($result['status_code']) ? $result['status_code'] : -1);
            $msg = isset($result['msg']) ? $result['msg'] : (isset($result['message']) ? $result['message'] : '创建订单失败');

            if ($code !== 0 && $code !== 200) {
                return array('code' => 1002, 'msg' => $msg, 'data' => $response);
            }

            $payUrl = isset($result['data']['payment_url']) ? $result['data']['payment_url'] : '';

            $resultData = array(
                'type' => 1,
                'paymethod' => $this->paymethod,
                'payname' => 'USDT',
                'url' => $payUrl,
                'overtime' => $payconfig['overtime'],
                'money' => $params['money'],
            );
            return array('code' => 1, 'msg' => 'success', 'data' => $resultData);
        } catch (\Exception $e) {
            return array('code' => 1000, 'msg' => $e->getMessage(), 'data' => '');
        }
    }

    public function notify($payconfig)
    {
        $body = file_get_contents('php://input');
        $params = json_decode($body, true);

        if (!$params || !isset($params['signature'])) {
            return 'error|no signature';
        }

        $secretKey = $payconfig['app_secret'];
        $callbackSig = $params['signature'];

        $signMap = array();
        foreach ($params as $k => $v) {
            if ($k === 'signature') continue;
            $signMap[$k] = (string)$v;
        }

        $expectedSig = $this->gmpaySign($signMap, $secretKey);
        if ($callbackSig !== $expectedSig) {
            return 'error|sign mismatch';
        }

        $orderNo = isset($params['order_id']) ? $params['order_id'] : '';
        $txHash = isset($params['tx_hash']) ? $params['tx_hash'] : '';
        if (empty($txHash)) {
            $txHash = isset($params['txid']) ? $params['txid'] : '';
        }

        if (empty($orderNo)) {
            return 'error|no order_id';
        }

        $config = array(
            'paymethod' => $this->paymethod,
            'tradeid' => $txHash,
            'paymoney' => isset($params['amount']) ? $params['amount'] : '0',
            'orderid' => $orderNo,
        );
        $notify = new \Pay\notify();
        $data = $notify->run($config);

        if ($data['code'] > 1) {
            return 'error|' . $data['msg'];
        }
        return 'success';
    }

    private function gmpaySign($params, $secretKey)
    {
        ksort($params);
        $buf = '';
        $i = 0;
        foreach ($params as $k => $v) {
            if ($i > 0) {
                $buf .= '&';
            }
            $buf .= $k . '=' . $v;
            $i++;
        }
        $buf .= $secretKey;
        return md5($buf);
    }
}
