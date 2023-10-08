import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'note',
    url: `${Host.ApiTakumiRecord}/game_record/app/hkrpg/api/note`,
    params: {
        role_id: '',
        server: ''
    },
    method: http.RequestMethod.GET
}