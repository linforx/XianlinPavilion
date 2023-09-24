import Reliquary from '../../../model/Game/GenshinImpact/Reliquary'

@Observed
export default class ReliquaryInfo extends Reliquary {
  public icon: string

  constructor(reliquary: Reliquary, icon: string) {
    super(
      reliquary.id,
      reliquary.name,
      reliquary.pos,
      reliquary.rarity,
      reliquary.level,
      reliquary.set,
      reliquary.mainStat,
      reliquary.subStats,
      reliquary.appendPropIdList
    )
    this.icon = icon
  }
}