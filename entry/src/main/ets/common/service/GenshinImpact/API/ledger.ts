/**
 * @FileName: ledger
 * @Author: Administrator
 * @Date: 2023/5/23 18:48
 * Description:
 */

import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'ledger',
    url: `${Host.Hk4eApi}/event/ys_ledger/monthInfo`,
    params: {
        month: 0,
        bind_uid: '',
        bind_region: ''
    },
    method: http.RequestMethod.GET
}