import data_preferences from '@ohos.data.preferences'
import common from '@ohos.app.ability.common'

let preference: data_preferences.Preferences = null

export default {
    async initAsync(context: common.BaseContext) {
        try {
            preference = await data_preferences.getPreferences(context, 'setting')
        } catch (err) {
            console.error('init app setting failed')
        }

        return preference != null
    },
    async getAsync(key: string) {
        try {
            return await preference.get(key, 'default')
        } catch (err) {
            return null
        }
    },
    async getAllAsync() {
        try {
            return await preference.getAll()
        } catch (err) {
            return null
        }
    },
    async putAsync(key: string, value: data_preferences.ValueType) {
        try {
            await preference.put(key, value)
            return true
        } catch (err) {
            console.error(`put ${key}(${value}) to setting preference failed: ${err}`)
            return false
        }
    },
    async hasAsync(key: string) {
        try {
            return await preference.has(key)
        } catch (err) {
            console.error(`get ${key} from setting preference failed: ${err}`)
            return false
        }
    },
    async deleteAsync(key: string) {
        try {
            await preference.delete(key)
            return true
        } catch (err) {
            console.error(`delete ${key} from setting preference failed: ${err}`)
            return false
        }
    },
    async flushAsync() {
        try {
            await preference.flush()
            return true
        } catch (err) {
            console.error(`flush setting preference failed: ${err}`)
            return false
        }
    },
    async clearAsync() {
        try {
            await preference.clear()
            return true
        } catch (err) {
            console.error(`clear setting preference failed: ${err}`)
            return false
        }
    },
    on(callback: (data: { key: string; }) => void) {
        preference.on('change', callback)
    },
    off(callback: (data: { key: string; }) => void) {
        preference.off('change', callback)
    }
}