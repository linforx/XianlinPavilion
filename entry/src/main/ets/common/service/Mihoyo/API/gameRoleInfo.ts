/**
 * @FileName: gameRoleInfo
 * @Author: Administrator
 * @Date: 2023/5/23 13:55
 * Description:
 */

import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'gameRoleInfo',
    url: `${Host.ApiTakumi}/binding/api/getUserGameRolesByCookieToken`,
    params: {},
    method: http.RequestMethod.GET
}