import WeaponBriefInfo from './WeaponBriefInfo'

@Observed
export default class AvatarBriefInfo {
  public id: number
  public name: string
  public element: string
  public rarity: number
  public icon: string
  public level: number
  public activedConstellation: number
  public weapon: WeaponBriefInfo
}