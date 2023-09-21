@Observed
export default class ConstellationInfo {
  public name: string
  public icon: string
  public wiki: string
  public index: number

  constructor(name: string, icon: string, wiki: string, index: number) {
    this.name = name;
    this.icon = icon;
    this.wiki = wiki;
    this.index = index;
  }
}