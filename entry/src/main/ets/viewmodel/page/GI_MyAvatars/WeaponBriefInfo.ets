@Observed
export default class WeaponBriefInfo {
  public id: number
  public name: string
  public type: string
  public rarity: number
  public icon: string
  public level: number
  public affixLevel: number

  constructor(
    id: number,
    name: string,
    type: string,
    rarity: number,
    icon: string,
    level: number,
    affixLevel: number
  ) {
    this.id = id;
    this.name = name;
    this.type = type;
    this.rarity = rarity;
    this.icon = icon;
    this.level = level;
    this.affixLevel = affixLevel;
  }
}