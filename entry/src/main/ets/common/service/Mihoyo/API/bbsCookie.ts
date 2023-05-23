/**
 * @FileName: bbsCookie
 * @Author: Administrator
 * @Date: 2023/5/23 13:51
 * Description:
 */

import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'getCookie',
    url: `${Host.ApiTakumi}/auth/api/getCookieAccountInfoBySToken`,
    params: {
        uid: 0,
        stoken: ''
    },
    method: http.RequestMethod.GET
}