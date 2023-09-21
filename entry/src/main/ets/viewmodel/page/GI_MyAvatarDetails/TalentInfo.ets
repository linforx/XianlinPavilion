@Observed
export default class TalentInfo {
  public name: string
  public icon: string
  public current_level: number
  public max_level: number
  public extraUpgrade: boolean = false
  public wiki: Object

  constructor(name: string, icon: string, current_level: number, max_level: number, wiki: any) {
    this.name = name;
    this.icon = icon;
    this.current_level = current_level;
    this.max_level = max_level;
    this.wiki = wiki;
  }
}