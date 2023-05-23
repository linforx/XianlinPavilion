/**
 * @FileName: actionTicket
 * @Author: Administrator
 * @Date: 2023/5/23 13:52
 * Description:
 */

import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'getActionTicketBySToken',
    url: `${Host.ApiTakumi}/auth/api/getActionTicketBySToken`,
    params: {
        'action_type': '',
        'stoken': '',
        'uid': ''
    },
    method: http.RequestMethod.GET
}