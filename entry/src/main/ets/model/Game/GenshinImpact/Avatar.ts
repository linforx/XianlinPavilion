import Reliquary from './Reliquary'
import Weapon from './Weapon'

interface skill {
    id: number,
    name: string,
    currentLevel: number,
    maxLevel: number
}

export default class Avatar {
    private _id: number;
    private _name: string;
    private _rarity: number;
    private _element: string;
    private _level: number;
    private _fetter: number;
    private _actived_constellation_num: number;
    private _costumeId: number;
    private _prop: object;
    private _weapon: Weapon;
    private _reliquaries: Reliquary[];
    private _skillList: skill[];

    constructor(
        id: number,
        name: string,
        rarity: number,
        element: string,
        level: number,
        fetter: number,
        actived_constellation_num: number,
        costumeId: number,
        weapon: Weapon,
        prop: object = {},
        reliquaries: Reliquary[] = [],
        skillList: skill[] = []
    ) {
        this._id = id;
        this._name = name;
        this._rarity = rarity;
        this._element = element;
        this._level = level;
        this._fetter = fetter;
        this._actived_constellation_num = actived_constellation_num;
        this._costumeId = costumeId;
        this._weapon = weapon;
        this._prop = prop ?? null;
        this._reliquaries = reliquaries ?? [];
        this._skillList = skillList ?? [];
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

    public get element(): string {
        return this._element;
    }

    public set element(value: string) {
        this._element = value;
    }

    public get level(): number {
        return this._level;
    }

    public set level(value: number) {
        this._level = value;
    }

    public get fetter(): number {
        return this._fetter;
    }

    public set fetter(value: number) {
        this._fetter = value;
    }

    public get actived_constellation_num(): number {
        return this._actived_constellation_num;
    }

    public set actived_constellation_num(value: number) {
        this._actived_constellation_num = value;
    }

    public get costumeId(): number {
        return this._costumeId;
    }

    public set costumeId(value: number) {
        this._costumeId = value;
    }

    public get prop(): object {
        return this._prop;
    }

    public set prop(value: object) {
        this._prop = value;
    }

    public get weapon(): Weapon {
        return this._weapon;
    }

    public set weapon(value: Weapon) {
        this._weapon = value;
    }

    public get reliquaries(): Reliquary[] {
        return this._reliquaries;
    }

    public set reliquaries(value: Reliquary[]) {
        this._reliquaries = value;
    }

    public get skillList(): skill[] {
        return this._skillList;
    }

    public set skillList(value: skill[]) {
        this._skillList = value;
    }

    public toJSON() {
        const weaponObj = this.weapon ? this.weapon.toJSON() : null;
        const reliquariesArr = this.reliquaries.map(reliquary => reliquary.toJSON());

        return {
            id: this.id ?? null,
            name: this.name ?? '',
            rarity: this.rarity ?? 0,
            element: this.element ?? '',
            level: this.level ?? 0,
            fetter: this.fetter ?? 0,
            actived_constellation_num: this.actived_constellation_num ?? 0,
            costumeId: this.costumeId ?? 0,
            prop: this.prop ?? {},
            weapon: weaponObj,
            reliquaries: reliquariesArr,
            skillList: this._skillList
        };
    }
}