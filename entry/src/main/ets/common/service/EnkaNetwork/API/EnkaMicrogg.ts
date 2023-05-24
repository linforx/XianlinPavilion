/**
 * @FileName: EnkaMicrogg
 * @Author: Administrator
 * @Date: 2023/5/24 18:11
 * Description:
 */

import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'EnkaMicrogg',
    url: `${Host.EnkaMicrogg}/api/uid/`,
    params: {},
    method: http.RequestMethod.GET
}