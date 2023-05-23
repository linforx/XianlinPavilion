/**
 * @FileName: createVerification
 * @Author: Administrator
 * @Date: 2023/5/23 16:48
 * Description:
 */

import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'createVerification',
    url: `${Host.ApiTakumiRecord}/game_record/app/card/wapi/createVerification`,
    params: {
        is_high: false
    },
    method: http.RequestMethod.GET
}