/**
 * @FileName: GameRole
 * @Author: Administrator
 * @Date: 2023/5/22 21:16
 * Description:
 */

export default class GameRole {
    public constructor(json_data: Object) {
        this.gameBiz = json_data['game_biz'] ?? ''
        this.region = json_data['region'] ?? ''
        this.regionName = json_data['region_name'] ?? ''
        this.gameUid = json_data['game_uid'] ?? ''
        this.nickname = json_data['nickname'] ?? ''
        this.level = json_data['level'] ?? ''
        this.isChosen = json_data['is_chosen'] ?? false
        this.isOfficial = json_data['is_official'] ?? true
    }
    
    public gameBiz: string = ''                 // 服务器代号
    public region: string = ''                  // 服务器
    public regionName: string = ''              // 服务器名称
    public gameUid: string = ''                 // 游戏UID
    public nickname: string = ''                // 游戏昵称
    public level: number = 0                    // 游戏等级
    public isChosen: boolean = false            // 是否选中（影响未知）
    public isOfficial: boolean = true           // 是否官方服务器角色
}