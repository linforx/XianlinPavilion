/**
 * @FileName: compute
 * @Author: Administrator
 * @Date: 2023/5/23 19:01
 * Description:
 */

import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'compute',
    url: `${Host.ApiTakumi}/event/e20200928calculate/v2/compute`,
    params: {},
    method: http.RequestMethod.POST,
    body: {}
}