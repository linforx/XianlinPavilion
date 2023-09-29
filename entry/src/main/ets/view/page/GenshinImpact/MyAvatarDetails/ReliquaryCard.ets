import ReliquaryInfo from '../../../../viewmodel/page/GI_MyAvatarDetails/ReliquaryInfo'

const AppendProp: Map<string, string> = new Map([
  ['FIGHT_PROP_BASE_ATTACK', '基础攻击力'],
  ['FIGHT_PROP_HP', '生命值'],
  ['FIGHT_PROP_ATTACK', '攻击力'],
  ['FIGHT_PROP_DEFENSE', '防御力'],
  ['FIGHT_PROP_HP_PERCENT', '生命加成'],
  ['FIGHT_PROP_ATTACK_PERCENT', '攻击加成'],
  ['FIGHT_PROP_DEFENSE_PERCENT', '防御加成'],
  ['FIGHT_PROP_CRITICAL', '暴击率'],
  ['FIGHT_PROP_CRITICAL_HURT', '暴击伤害'],
  ['FIGHT_PROP_CHARGE_EFFICIENCY', '元素充能'],
  ['FIGHT_PROP_HEAL_ADD', '治疗加成'],
  ['FIGHT_PROP_ELEMENT_MASTERY', '元素精通'],
  ['FIGHT_PROP_PHYSICAL_ADD_HURT', '物伤加成'],
  ['FIGHT_PROP_FIRE_ADD_HURT', '火伤加成'],
  ['FIGHT_PROP_ELEC_ADD_HURT', '雷伤加成'],
  ['FIGHT_PROP_WATER_ADD_HURT', '水伤加成'],
  ['FIGHT_PROP_WIND_ADD_HURT', '风伤加成'],
  ['FIGHT_PROP_ICE_ADD_HURT', '冰伤加成'],
  ['FIGHT_PROP_ROCK_ADD_HURT', '岩伤加成'],
  ['FIGHT_PROP_GRASS_ADD_HURT', '草伤加成']
])

const propUnit: Map<string, string> = new Map([
  ['FIGHT_PROP_BASE_ATTACK', ''],
  ['FIGHT_PROP_HP', ''],
  ['FIGHT_PROP_ATTACK', ''],
  ['FIGHT_PROP_DEFENSE', ''],
  ['FIGHT_PROP_HP_PERCENT', '%'],
  ['FIGHT_PROP_ATTACK_PERCENT', '%'],
  ['FIGHT_PROP_DEFENSE_PERCENT', '%'],
  ['FIGHT_PROP_CRITICAL', '%'],
  ['FIGHT_PROP_CRITICAL_HURT', '%'],
  ['FIGHT_PROP_CHARGE_EFFICIENCY', '%'],
  ['FIGHT_PROP_HEAL_ADD', '%'],
  ['FIGHT_PROP_ELEMENT_MASTERY', ''],
  ['FIGHT_PROP_PHYSICAL_ADD_HURT', '%'],
  ['FIGHT_PROP_FIRE_ADD_HURT', '%'],
  ['FIGHT_PROP_ELEC_ADD_HURT', '%'],
  ['FIGHT_PROP_WATER_ADD_HURT', '%'],
  ['FIGHT_PROP_WIND_ADD_HURT', '%'],
  ['FIGHT_PROP_ICE_ADD_HURT', '%'],
  ['FIGHT_PROP_ROCK_ADD_HURT', '%'],
  ['FIGHT_PROP_GRASS_ADD_HURT', '%']
])

@Component
export default struct ReliquaryCard {
  private reliquary: ReliquaryInfo

  build() {
    Column({ space: 4 }) {
      Row({ space: 4 }) {
        Column() {
          Image($rawfile(`GI/resource/${this.reliquary.set}/${this.reliquary.icon}.webp`))
            .width(22)
            .aspectRatio(1)
        }
        .width(28)
        .aspectRatio(1)
        .justifyContent(FlexAlign.Center)
        .backgroundImage($rawfile(`GI/resource/others/RarityBGI/bg${this.reliquary.rarity}.png`))
        .backgroundImageSize(ImageSize.Contain)
        .borderRadius(5)


        Column({ space: 5 }) {
          Text(this.reliquary.name)
            .fontSize(13)
            .fontColor(Color.White)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Clip })
          Text(`Lv: ${this.reliquary.level}`)
            .fontSize(13)
            .fontColor('#B3FFFFFF')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.SpaceBetween)
        .height(28)
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')

      if (this.reliquary.mainStat) {
        Row() {
          Text(AppendProp.get(this.reliquary.mainStat.key))
            .fontSize(13)
            .fontColor('#B3FFFFFF')
            .fontWeight(FontWeight.Bold)

          Text(`${this.reliquary.mainStat.value}${propUnit.get(this.reliquary.mainStat.key)} `)
            .fontSize(13)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .width('100%')
        .margin({ top: 5 })

        List({ space: 4 }) {
          ForEach(this.reliquary.subStats, (item) => {
            ListItem() {
              Row() {
                Text(AppendProp.get(item.key))
                  .fontSize(12)
                  .fontColor('#F1F1F1')

                Text(`${item.value}${propUnit.get(item.key)} `)
                  .fontSize(12)
                  .fontColor('#F1F1F1')
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .width('100%')
            }
          })
        }
        .divider({ startMargin: 0, endMargin: 0, strokeWidth: 2 })
        .margin({ top: 5 })
      }
    }
    .padding(5)
    .width('100%')
    .backgroundColor('#4D000000')
    .shadow({ color: '#4000001E', radius: 20 })
    .borderRadius(10)
  }
}