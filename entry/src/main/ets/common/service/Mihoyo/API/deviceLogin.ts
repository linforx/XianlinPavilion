/**
 * @FileName: deviceLogin
 * @Author: Administrator
 * @Date: 2023/6/2 15:21
 * Description:
 */

import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'deviceLogin',
    url: `${Host.BbsApi}/apihub/api/deviceLogin`,
    params: {},
    body: {
        'app_version': '',
        'device_id': '',
        'device_name': '',
        'os_version': '',
        'platform': '',
        'registration_id': ''
    },
    method: http.RequestMethod.POST
}