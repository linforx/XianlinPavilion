import relationalStore from '@ohos.data.relationalStore'

const TABLE_NAME: string = 'account'
const FIELDS: string[] = ['id', 'account_id', 'cookies']
const SQL_CREATE_TABLE = `CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (` +
'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,' +
'account_id TEXT DEFAULT \'\',' +
'cookies TEXT DEFAULT \'\'' +
');'
const SQL_DROP_TABLE = `DROP TABLE ${TABLE_NAME};`

export default {
    name: TABLE_NAME,
    fields: FIELDS,
    async init(storage: relationalStore.RdbStore) {
        await storage.executeSql(SQL_CREATE_TABLE)
    },
    async drop(storage: relationalStore.RdbStore) {
        await storage.executeSql(SQL_DROP_TABLE)
    }
}