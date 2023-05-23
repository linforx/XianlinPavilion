/**
 * @FileName: newsList
 * @Author: Administrator
 * @Date: 2023/5/23 16:46
 * Description:
 */

import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'newsList',
    url: `${Host.BbsApi}/post/wapi/getNewsList`,
    params: {
        gids: 2,
        page_size: 10,
        type: 1,
        last_id: 0
    },
    method: http.RequestMethod.GET
}