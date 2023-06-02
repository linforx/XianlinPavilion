/**
 * @FileName: saveDevice
 * @Author: Administrator
 * @Date: 2023/6/2 15:25
 * Description:
 */

import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'saveDevice',
    url: `${Host.BbsApi}/apihub/api/saveDevice`,
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