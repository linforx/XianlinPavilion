/**
 * @FileName: postFull
 * @Author: Administrator
 * @Date: 2023/5/23 16:47
 * Description:
 */

import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'getPostFull',
    url: `${Host.BbsApi}/post/wapi/getPostFull`,
    params: {
        gids: 2,
        post_id: 10,
        read: 1
    },
    method: http.RequestMethod.GET
}