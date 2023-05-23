/**
 * @FileName: verifyVerification
 * @Author: Administrator
 * @Date: 2023/5/23 16:48
 * Description:
 */

import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'verifyVerification',
    url: `${Host.ApiTakumiRecord}/game_record/app/card/wapi/verifyVerification`,
    params: {},
    method: http.RequestMethod.POST,
    body: {
        geetest_seccode: '',
        geetest_challenge: '',
        geetest_validate: ''
    }
}