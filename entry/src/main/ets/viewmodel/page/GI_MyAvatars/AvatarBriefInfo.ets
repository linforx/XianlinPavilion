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

  constructor(
    id: number,
    name: string,
    element: string,
    rarity: number,
    icon: string,
    level: number,
    activedConstellation: number,
    weapon: WeaponBriefInfo
  ) {
    this.id = id;
    this.name = name;
    this.element = element;
    this.rarity = rarity;
    this.icon = icon;
    this.level = level;
    this.activedConstellation = activedConstellation;
    this.weapon = weapon;
  }
}