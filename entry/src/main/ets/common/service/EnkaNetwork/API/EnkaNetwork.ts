/**
 * @FileName: EnkaNetwork
 * @Author: Administrator
 * @Date: 2023/5/24 18:00
 * Description:
 */

import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'EnkaNetwork',
    url: `${Host.EnkaNetwork}/api/uid/`,
    params: {},
    method: http.RequestMethod.GET
}