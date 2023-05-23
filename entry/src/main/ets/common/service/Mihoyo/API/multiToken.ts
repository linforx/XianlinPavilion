/**
 * @FileName: multiToken
 * @Author: Administrator
 * @Date: 2023/5/23 13:50
 * Description:
 */

import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'multiToken',
    url: `${Host.ApiTakumi}/auth/api/getMultiTokenByLoginTicket`,
    params: {
        login_ticket: '',
        token_types: 3,
        uid: 0
    },
    method: http.RequestMethod.GET
}