import common from '@ohos.app.ability.common'
import relationalStore from '@ohos.data.relationalStore'
import tableAccount from './tables/account'

const STORE_CONFIG = {
    name: "BudgetHelper.db",
    securityLevel: relationalStore.SecurityLevel.S1
};

let DBHelper: DatabaseHelper = null

class DatabaseHelper {
    private context: common.Context = null
    private storage: relationalStore.RdbStore = null

    public constructor(context: common.Context) {
        this.context = context
    }

    // 获取数据库并初始化表结构
    public async initStorageAsync() {               // 初始化数据库与表结构
        if (!this.context) {
            console.error('cannot init storage without context')
            return false
        }

        this.storage = await relationalStore.getRdbStore(this.context, STORE_CONFIG)
        if (!this.storage) {
            console.error('cannot obtain rdb storage')
            return false
        }

        try {
            await tableAccount.init(this.storage)
            console.info('table account init done')
        } catch(err) {
            console.error('table accout init failed: ' + err)
        }

        console.info('init storage done')
        return true
    }

    // 在表 account 中查询并返回结果列表
    public async queryInTableAccountAsync(predicates: relationalStore.RdbPredicates, fields?: string[]) {
        if (!this.storage) throw new Error('Storage is null, please init at first')

        let resultSet = await this.storage.query(predicates, fields)
        resultSet.goToFirstRow()
        let results = []
        fields == fields ?? tableAccount.fields
        for (let i = 0; i < resultSet.rowCount; ++i) {
            let obj = {}
            for (let field of fields) {
                switch(field) {
                    case 'id':
                        obj[field] = resultSet.getLong(resultSet.getColumnIndex(field))
                        break
                    case 'account_id':
                        obj[field] = resultSet.getString(resultSet.getColumnIndex(field))
                        break
                    case 'cookies':
                        obj[field] = resultSet.getString(resultSet.getColumnIndex(field))
                        break
                }
            }
            results.push(obj)

            resultSet.goToNextRow()
        }
        return results
    }

    // 向指定表中插入数据，成功返回插入行的id，失败则返回-1
    public async insertToTableAsync(tableName: string, valueBucket: {}) {
        if (!this.storage) throw new Error('Storage is null, please init at first')

        let rowId = await this.storage.insert(tableName, valueBucket)

        return rowId
    }

    // 查询指定表中是否存在某条数据
    public async existInTableAsync(predicates: relationalStore.RdbPredicates) {
        if (!this.storage) throw new Error('Storage is null, please init at first')

        let resultSet = await this.storage.query(predicates, ['id'])

        return resultSet.rowCount > 0
    }

    // 在指定表中更新数据，成功返回受影响的行数
    public async updateInTableAsync(predicates: relationalStore.RdbPredicates, valueBucket: {}) {
        if (!this.storage) throw new Error('Storage is null, please init at first')

        let rowCount = await this.storage.update(valueBucket, predicates)

        return rowCount
    }

    // 在指定表中删除数据，成功返回受影响的行数
    public async deleteInTableAsync(predicates: relationalStore.RdbPredicates) {
        if (!this.storage) throw new Error('Storage is null, please init at first')

        let rowCount = await this.storage.delete(predicates)

        return rowCount
    }

    // 从数据库中删除指定表
    public async dropTableAsync(tableName: string) {
        switch(tableName) {
            case 'account':
                await tableAccount.drop(this.storage)
                break
        }
    }
}

const getDBHelper = (context: common.Context) => {
    if (DBHelper) return DBHelper;
    DBHelper = new DatabaseHelper(context)
    return DBHelper
}

export { DatabaseHelper, getDBHelper }