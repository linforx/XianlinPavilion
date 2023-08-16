interface Stat {
    key: string,
    value: number
}

export default class Reliquary {
    private _id: number;
    private _name: string;
    private _pos: number;
    private _rarity: number;
    private _level: number;
    private _set: number;
    private _mainStat: Stat;
    private _subStats: Stat[];

    constructor(
        id: number,
        name: string,
        pos: number,
        rarity: number,
        level: number,
        set: number,
        mainStat?: Stat,
        subStats?: Stat[]
    ) {
        this._id = id;
        this._name = name;
        this._pos = pos;
        this._rarity = rarity;
        this._level = level;
        this._set = set;
        this._mainStat = mainStat ?? null;
        this._subStats = subStats ?? [];
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

    public get pos(): number {
        return this._pos;
    }

    public set pos(value: number) {
        this._pos = value;
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

    public get set(): number {
        return this._set;
    }

    public set set(value: number) {
        this._set = value;
    }

    public get mainStat(): Stat {
        return this._mainStat;
    }

    public set mainStat(value: Stat) {
        this._mainStat = value;
    }

    public get subStats(): Stat[] {
        return this._subStats;
    }

    public set subStats(value: Stat[]) {
        this._subStats = value;
    }

    public toJSON() {
        const mainStatObj = this.mainStat ? { key: this.mainStat.key ?? null, value: this.mainStat.value ?? 0 } : null;
        const subStatsObj = this.subStats.map(stat => ({ key: stat.key ?? null, value: stat.value ?? 0 }));

        return {
            id: this.id ?? null,
            name: this.name ?? '',
            pos: this.pos ?? 0,
            rarity: this.rarity ?? 0,
            level: this.level ?? 0,
            set: this.set ?? 0,
            mainStat: mainStatObj,
            subStats: subStatsObj
        };
    }
}
