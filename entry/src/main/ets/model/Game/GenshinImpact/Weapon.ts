interface Stat {
    key: string,
    value: number
}

export default class Weapon {
    private _id: number;
    private _name: string;
    private _rarity: number;
    private _level: number;
    private _affixLevel: number;
    private _mainStat: Stat;
    private _subStat: Stat;

    constructor(
        id: number,
        name: string,
        rarity: number,
        level: number,
        affixLevel: number,
        mainStat?: Stat,
        subStat?: Stat
    ) {
        this._id = id;
        this._name = name;
        this._rarity = rarity;
        this._level = level;
        this._affixLevel = affixLevel;
        this._mainStat = mainStat ?? null;
        this._subStat = subStat ?? null;
    }

    public get id(): number {
        return this._id;
    }

    public set id(value: number) {
        this._id = value;
    }

    public get name(): string {
        return this._name;
    }

    public set name(value: string) {
        this._name = value;
    }

    public get rarity(): number {
        return this._rarity;
    }

    public set rarity(value: number) {
        this._rarity = value;
    }

    public get level(): number {
        return this._level;
    }

    public set level(value: number) {
        this._level = value;
    }

    public get affixLevel(): number {
        return this._affixLevel;
    }

    public set affixLevel(value: number) {
        this._affixLevel = value;
    }

    public get mainStat(): Stat {
        return this._mainStat;
    }

    public set mainStat(value: Stat) {
        this._mainStat = value;
    }

    public get subStat(): Stat {
        return this._subStat;
    }

    public set subStat(value: Stat) {
        this._subStat = value;
    }

    public toJSON() {
        const mainStatObj = this.mainStat ? { key: this.mainStat.key ?? null, value: this.mainStat.value ?? 0 } : null;
        const subStatObj = this.subStat ? { key: this.subStat.key ?? null, value: this.subStat.value ?? 0 } : null;

        return {
            id: this.id ?? null,
            name: this.name ?? '',
            rarity: this.rarity ?? 0,
            level: this.level ?? 0,
            affixLevel: this.affixLevel ?? 0,
            mainStat: mainStatObj,
            subStat: subStatObj
        };
    }
}
