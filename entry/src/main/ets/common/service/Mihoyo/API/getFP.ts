import Host from '../../Host';
import http from '@ohos.net.http';

export default {
    name: 'getFP',
    url: `${Host.PublicDataApi}/device-fp/api/getFp`,
    params: {},
    body: {
        seed_id: '',
        device_id: '',
        platform: '5',
        seed_time: '',
        ext_fields: '{"userAgent":"Mozilla/5.0 (iPhone; CPU iPhone OS 16_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.40.1","browserScreenSize":281520,"maxTouchPoints":5,"isTouchSupported":true,"browserLanguage":"zh-CN","browserPlat":"iPhone","browserTimeZone":"Asia/Shanghai","webGlRender":"Apple GPU","webGlVendor":"Apple Inc.","numOfPlugins":0,"listOfPlugins":"unknown","screenRatio":3,"deviceMemory":"unknown","hardwareConcurrency":"4","cpuClass":"unknown","ifNotTrack":"unknown","ifAdBlock":0,"hasLiedResolution":1,"hasLiedOs":0,"hasLiedBrowser":0}',
        app_name: 'bbs_cn',
        device_fp: ''
    },
    method: http.RequestMethod.POST
}