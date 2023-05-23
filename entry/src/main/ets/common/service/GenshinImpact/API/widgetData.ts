/**
 * @FileName: widgetData
 * @Author: Administrator
 * @Date: 2023/5/23 21:01
 * Description:
 */

import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'widgetData',
    url: `${Host.ApiTakumiRecord}/game_record/app/card/api/getWidgetData`,
    params: {
        game_id: 2
    },
    method: http.RequestMethod.GET
}