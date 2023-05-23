/**
 * @FileName: Response
 * @Author: Administrator
 * @Date: 2023/5/23 13:42
 * Description:
 */

class Response {
    public success: boolean     // 该请求响应是否成功返回预期的数据
    public code: number         // 该请求响应的业务码
    public message: string      // 该请求响应的描述
    public data: string         // 该请求响应的正式内容
    public timeCost: number     // 该请求消耗的时间，单位ms
}

export default Response