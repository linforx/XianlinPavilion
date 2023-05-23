/**
 * @FileName: userInfo
 * @Author: Administrator
 * @Date: 2023/5/23 13:54
 * Description:
 */

import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'userInfo',
    url: `${Host.BbsApi}/user/wapi/getUserFullInfo`,
    params: {},
    method: http.RequestMethod.GET
}