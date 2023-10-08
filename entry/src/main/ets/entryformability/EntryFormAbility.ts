import formInfo from '@ohos.app.form.formInfo';
import formBindingData from '@ohos.app.form.formBindingData';
import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import formProvider from '@ohos.app.form.formProvider';
import FileManager from '../common/utils/FileManager';
import Config from '../model/config'
import GenshinAPI from '../model/ServiceProvider/GenshinAPI';
import DynamicSecretVersion from '../common/service/DynamicSecretVersion';
import SaltType from '../common/service/SaltType';
import GI_DailyNoteInfo from '../viewmodel/page/Index/GI_DailyNoteInfo';
import StarRailAPI from '../model/ServiceProvider/StarRailAPI';
import HSR_NoteInfo from '../viewmodel/page/Index/HSR_NoteInfo';
import dataStorage from '@ohos.data.storage';

export default class EntryFormAbility extends FormExtensionAbility {
    onAddForm(want) {
        // Called to return a FormBindingData object.
        console.warn('onAddForm')
        let dimension =  want.parameters[formInfo.FormParam.DIMENSION_KEY]
        let isTempCard: boolean = want.parameters[formInfo.FormParam.TEMPORARY_KEY]
        console.warn(`card dimension: ${dimension}`)
        console.warn(`是否常态化卡片: ${!isTempCard}`)
        console.warn(JSON.stringify(want))

        let formData = {
            dimension: dimension,
        };

        let fileManager: FileManager = new FileManager(this.context)
        let config: Config
        try {
            let path = `/config/config.json`
            let text = fileManager.readText(path)
            config = JSON.parse(text) as any

            console.warn(`config: ${text}`)
            console.warn('读取config配置成功')
            let formId: string = want.parameters[formInfo.FormParam.IDENTITY_KEY]
            let storeDB = dataStorage.getStorageSync(this.context.filesDir + 'FormStore')
            storeDB.putSync(`${formId}-name`, want.parameters[formInfo.FormParam.NAME_KEY])
            storeDB.flushSync()

            switch (want.parameters[formInfo.FormParam.NAME_KEY]) {
                case 'GenshinDailyNote': {
                    if (config.selected_account.genshin_impact.selected_role.uid) {
                        formData['uid'] = config.selected_account.genshin_impact.selected_role.uid
                    }

                    console.warn('从网络中拉取数据')
                    let binding = formBindingData.createFormBindingData({ message: '正在刷新' })
                    formProvider.updateForm(formId, binding)
                        .then((data) => {
                            console.info('FormAbility updateForm success.' + JSON.stringify(data));
                        }).catch((error) => {
                        console.error('FormAbility updateForm failed: ' + JSON.stringify(error));
                    })
                    new GenshinAPI()
                        .applyDailyNote(config.selected_account.genshin_impact.selected_role.uid, config.selected_account.genshin_impact.selected_role.server)
                        .setCookie(config.selected_account.cookie)
                        .setReferer('https://webstatic.mihoyo.com/')
                        .HeadersAddWith('x-rpc-device_fp', '38d7ee834d1e9')
                        .HeadersAddWith('x-rpc-device_id', '5f3b6eec-58a4-3a6d-b544-51566d011b42')
                        .useDynamicSecret(DynamicSecretVersion.V2, SaltType.X4)
                        .getResponseAsync()
                        .then((response) => {
                            if (!response.success) {
                                console.error('获取原神体力数据失败: ' + response.message)
                                if (!response.success) {
                                    console.error('获取原神体力数据失败: ' + response.message)
                                    let formData = {
                                        uid: config.selected_account.genshin_impact.selected_role.uid,
                                        loaded: false,
                                        message: response.message
                                    }
                                    let formInfo = formBindingData.createFormBindingData(formData)

                                    formProvider.updateForm(formId, formInfo)
                                        .then((data) => {
                                            console.info('FormAbility updateForm success.' + JSON.stringify(data));
                                        }).catch((error) => {
                                        console.error('FormAbility updateForm failed: ' + JSON.stringify(error));
                                    })
                                    return null
                                }
                                return null
                            }
                            console.warn('获取原神体力数据成功')

                            let json = JSON.parse(response.data)
                            let dailyNoteData: GI_DailyNoteInfo = new GI_DailyNoteInfo(json)

                            let formData = {
                                dimension: dimension,
                                uid: config.selected_account.genshin_impact.selected_role.uid,
                                loaded: true,
                                ...dailyNoteData.toJSON()
                            }

                            let formInfo = formBindingData.createFormBindingData(formData)

                            formProvider.updateForm(formId, formInfo)
                                .then((data) => {
                                    console.info('FormAbility updateForm success.' + JSON.stringify(data));
                                }).catch((error) => {
                                console.error('FormAbility updateForm failed: ' + JSON.stringify(error));
                            })
                        })

                    break
                }
                case 'StarRailNote': {
                    if (config.selected_account.star_rail.selected_role.uid) {
                        formData['uid'] = config.selected_account.star_rail.selected_role.uid
                    }

                    let formId: string = want.parameters[formInfo.FormParam.IDENTITY_KEY]
                    console.warn('从网络中拉取数据')
                    let binding = formBindingData.createFormBindingData({ message: '正在刷新' })
                    formProvider.updateForm(formId, binding)
                        .then((data) => {
                            console.info('FormAbility updateForm success.' + JSON.stringify(data));
                        }).catch((error) => {
                        console.error('FormAbility updateForm failed: ' + JSON.stringify(error));
                    })
                    new StarRailAPI()
                        .applyNote(config.selected_account.star_rail.selected_role.uid, config.selected_account.star_rail.selected_role.server)
                        .setCookie(config.selected_account.cookie)
                        .setReferer('https://webstatic.mihoyo.com/')
                        .HeadersAddWith('x-rpc-device_fp', '38d7ee834d1e9')
                        .HeadersAddWith('x-rpc-device_id', '5f3b6eec-58a4-3a6d-b544-51566d011b42')
                        .useDynamicSecret(DynamicSecretVersion.V2, SaltType.X4)
                        .getResponseAsync()
                        .then((response) => {
                            if (!response.success) {
                                console.error('获取星穹铁道体力数据失败: ' + response.message)
                                if (!response.success) {
                                    console.error('获取星穹铁道体力数据失败: ' + response.message)
                                    let formData = {
                                        uid: config.selected_account.genshin_impact.selected_role.uid,
                                        loaded: false,
                                        message: response.message
                                    }
                                    let formInfo = formBindingData.createFormBindingData(formData)

                                    formProvider.updateForm(formId, formInfo)
                                        .then((data) => {
                                            console.info('FormAbility updateForm success.' + JSON.stringify(data));
                                        }).catch((error) => {
                                        console.error('FormAbility updateForm failed: ' + JSON.stringify(error));
                                    })
                                    return null
                                }
                                return null
                            }
                            console.warn('获取星穹铁道体力数据成功')

                            let json = JSON.parse(response.data)
                            let noteData: HSR_NoteInfo = new HSR_NoteInfo(json)

                            let formData = {
                                dimension: dimension,
                                uid: config.selected_account.genshin_impact.selected_role.uid,
                                loaded: true,
                                ...noteData.toJSON()
                            }

                            let formInfo = formBindingData.createFormBindingData(formData)

                            formProvider.updateForm(formId, formInfo)
                                .then((data) => {
                                    console.info('FormAbility updateForm success.' + JSON.stringify(data));
                                }).catch((error) => {
                                console.error('FormAbility updateForm failed: ' + JSON.stringify(error));
                            })
                        })

                    break
                }
            }
        } catch (err) {
            console.error('读取config配置错误 code: ' + err.code)
            formData['message'] = '读取配置信息错误'
            return formBindingData.createFormBindingData(formData);
        }

        return formBindingData.createFormBindingData(formData);
    }

    onCastToNormalForm(formId) {
        // Called when the form provider is notified that a temporary form is successfully
        // converted to a normal form.
        console.warn('onCastToNormalForm')
    }

    onUpdateForm(formId) {
        // Called to notify the form provider to update a specified form.
        console.warn('onUpdateForm' + formId)
        let fileManager: FileManager = new FileManager(this.context)
        let config: Config
        let storeDB = dataStorage.getStorageSync(this.context.filesDir + 'FormStore')
        let cardName = storeDB.getSync(`${formId}-name`, '').toString()
        try {
            let path = `/config/config.json`
            let text = fileManager.readText(path)
            config = JSON.parse(text) as any

            console.warn(`config: ${text}`)
            console.warn('读取config配置成功')

            switch (cardName) {
                case 'GenshinDailyNote': {
                    console.warn('从网络中拉取数据')
                    let binding = formBindingData.createFormBindingData({ message: '正在刷新' })
                    formProvider.updateForm(formId, binding)
                        .then((data) => {
                            console.info('FormAbility updateForm success.' + JSON.stringify(data));
                        }).catch((error) => {
                        console.error('FormAbility updateForm failed: ' + JSON.stringify(error));
                    })
                    new GenshinAPI()
                        .applyDailyNote(config.selected_account.genshin_impact.selected_role.uid, config.selected_account.genshin_impact.selected_role.server)
                        .setCookie(config.selected_account.cookie)
                        .setReferer('https://webstatic.mihoyo.com/')
                        .HeadersAddWith('x-rpc-device_fp', '38d7ee834d1e9')
                        .HeadersAddWith('x-rpc-device_id', '5f3b6eec-58a4-3a6d-b544-51566d011b42')
                        .useDynamicSecret(DynamicSecretVersion.V2, SaltType.X4)
                        .getResponseAsync()
                        .then((response) => {
                            if (!response.success) {
                                console.error('获取原神体力数据失败: ' + response.message)
                                if (!response.success) {
                                    console.error('获取原神体力数据失败: ' + response.message)
                                    let formData = {
                                        uid: config.selected_account.genshin_impact.selected_role.uid,
                                        loaded: false,
                                        message: response.message
                                    }
                                    let formInfo = formBindingData.createFormBindingData(formData)

                                    formProvider.updateForm(formId, formInfo)
                                        .then((data) => {
                                            console.info('FormAbility updateForm success.' + JSON.stringify(data));
                                        }).catch((error) => {
                                        console.error('FormAbility updateForm failed: ' + JSON.stringify(error));
                                    })
                                    return null
                                }
                                return null
                            }
                            console.warn('获取原神体力数据成功')

                            let json = JSON.parse(response.data)
                            let dailyNoteData: GI_DailyNoteInfo = new GI_DailyNoteInfo(json)

                            let formData = {
                                uid: config.selected_account.genshin_impact.selected_role.uid,
                                loaded: true,
                                ...dailyNoteData.toJSON()
                            }

                            let formInfo = formBindingData.createFormBindingData(formData)

                            formProvider.updateForm(formId, formInfo)
                                .then((data) => {
                                    console.info('FormAbility updateForm success.' + JSON.stringify(data));
                                }).catch((error) => {
                                console.error('FormAbility updateForm failed: ' + JSON.stringify(error));
                            })
                        })

                    break
                }
                case 'StarRailNote': {
                    console.warn('从网络中拉取数据')
                    let binding = formBindingData.createFormBindingData({ message: '正在刷新' })
                    formProvider.updateForm(formId, binding)
                        .then((data) => {
                            console.info('FormAbility updateForm success.' + JSON.stringify(data));
                        }).catch((error) => {
                        console.error('FormAbility updateForm failed: ' + JSON.stringify(error));
                    })
                    new StarRailAPI()
                        .applyNote(config.selected_account.star_rail.selected_role.uid, config.selected_account.star_rail.selected_role.server)
                        .setCookie(config.selected_account.cookie)
                        .setReferer('https://webstatic.mihoyo.com/')
                        .HeadersAddWith('x-rpc-device_fp', '38d7ee834d1e9')
                        .HeadersAddWith('x-rpc-device_id', '5f3b6eec-58a4-3a6d-b544-51566d011b42')
                        .useDynamicSecret(DynamicSecretVersion.V2, SaltType.X4)
                        .getResponseAsync()
                        .then((response) => {
                            if (!response.success) {
                                console.error('获取星穹铁道体力数据失败: ' + response.message)
                                if (!response.success) {
                                    console.error('获取星穹铁道体力数据失败: ' + response.message)
                                    let formData = {
                                        uid: config.selected_account.genshin_impact.selected_role.uid,
                                        loaded: false,
                                        message: response.message
                                    }
                                    let formInfo = formBindingData.createFormBindingData(formData)

                                    formProvider.updateForm(formId, formInfo)
                                        .then((data) => {
                                            console.info('FormAbility updateForm success.' + JSON.stringify(data));
                                        }).catch((error) => {
                                        console.error('FormAbility updateForm failed: ' + JSON.stringify(error));
                                    })
                                    return null
                                }
                                return null
                            }
                            console.warn('获取星穹铁道体力数据成功')

                            let json = JSON.parse(response.data)
                            let noteData: HSR_NoteInfo = new HSR_NoteInfo(json)

                            let formData = {
                                uid: config.selected_account.genshin_impact.selected_role.uid,
                                loaded: true,
                                ...noteData.toJSON()
                            }

                            let formInfo = formBindingData.createFormBindingData(formData)

                            formProvider.updateForm(formId, formInfo)
                                .then((data) => {
                                    console.info('FormAbility updateForm success.' + JSON.stringify(data));
                                }).catch((error) => {
                                console.error('FormAbility updateForm failed: ' + JSON.stringify(error));
                            })
                        })

                    break
                }
            }
        } catch (err) {
            console.error('读取config配置错误 code: ' + err.code)
        }

    }

    onChangeFormVisibility(newStatus) {
        // Called when the form provider receives form events from the system.
    }

    onFormEvent(formId, message) {
        // Called when a specified message event defined by the form provider is triggered.
        console.info(`FormAbility onEvent, formId = ${formId}, message: ${JSON.stringify(message)}`);
        let update = JSON.parse(message)['update']
        let cardName = JSON.parse(message)['name']
        console.warn(JSON.stringify(update))
        if (update) {
            let fileManager: FileManager = new FileManager(this.context)
            let config: Config
            try {
                let path = `/config/config.json`
                let text = fileManager.readText(path)
                config = JSON.parse(text) as any

                console.warn(`config: ${text}`)
                console.warn('读取config配置成功')

                switch (cardName) {
                    case 'GenshinDailyNote': {
                        console.warn('从网络中拉取数据')
                        let binding = formBindingData.createFormBindingData({ message: '正在刷新' })
                        formProvider.updateForm(formId, binding)
                            .then((data) => {
                                console.info('FormAbility updateForm success.' + JSON.stringify(data));
                            }).catch((error) => {
                            console.error('FormAbility updateForm failed: ' + JSON.stringify(error));
                        })
                        new GenshinAPI()
                            .applyDailyNote(config.selected_account.genshin_impact.selected_role.uid, config.selected_account.genshin_impact.selected_role.server)
                            .setCookie(config.selected_account.cookie)
                            .setReferer('https://webstatic.mihoyo.com/')
                            .HeadersAddWith('x-rpc-device_fp', '38d7ee834d1e9')
                            .HeadersAddWith('x-rpc-device_id', '5f3b6eec-58a4-3a6d-b544-51566d011b42')
                            .useDynamicSecret(DynamicSecretVersion.V2, SaltType.X4)
                            .getResponseAsync()
                            .then((response) => {
                                if (!response.success) {
                                    console.error('获取原神体力数据失败: ' + response.message)
                                    if (!response.success) {
                                        console.error('获取原神体力数据失败: ' + response.message)
                                        let formData = {
                                            uid: config.selected_account.genshin_impact.selected_role.uid,
                                            loaded: false,
                                            message: response.message
                                        }
                                        let formInfo = formBindingData.createFormBindingData(formData)

                                        formProvider.updateForm(formId, formInfo)
                                            .then((data) => {
                                                console.info('FormAbility updateForm success.' + JSON.stringify(data));
                                            }).catch((error) => {
                                            console.error('FormAbility updateForm failed: ' + JSON.stringify(error));
                                        })
                                        return null
                                    }
                                    return null
                                }
                                console.warn('获取原神体力数据成功')

                                let json = JSON.parse(response.data)
                                let dailyNoteData: GI_DailyNoteInfo = new GI_DailyNoteInfo(json)

                                let formData = {
                                    uid: config.selected_account.genshin_impact.selected_role.uid,
                                    loaded: true,
                                    ...dailyNoteData.toJSON()
                                }

                                let formInfo = formBindingData.createFormBindingData(formData)

                                formProvider.updateForm(formId, formInfo)
                                    .then((data) => {
                                        console.info('FormAbility updateForm success.' + JSON.stringify(data));
                                    }).catch((error) => {
                                    console.error('FormAbility updateForm failed: ' + JSON.stringify(error));
                                })
                            })

                        break
                    }
                    case 'StarRailNote': {
                        console.warn('从网络中拉取数据')
                        let binding = formBindingData.createFormBindingData({ message: '正在刷新' })
                        formProvider.updateForm(formId, binding)
                            .then((data) => {
                                console.info('FormAbility updateForm success.' + JSON.stringify(data));
                            }).catch((error) => {
                            console.error('FormAbility updateForm failed: ' + JSON.stringify(error));
                        })
                        new StarRailAPI()
                            .applyNote(config.selected_account.star_rail.selected_role.uid, config.selected_account.star_rail.selected_role.server)
                            .setCookie(config.selected_account.cookie)
                            .setReferer('https://webstatic.mihoyo.com/')
                            .HeadersAddWith('x-rpc-device_fp', '38d7ee834d1e9')
                            .HeadersAddWith('x-rpc-device_id', '5f3b6eec-58a4-3a6d-b544-51566d011b42')
                            .useDynamicSecret(DynamicSecretVersion.V2, SaltType.X4)
                            .getResponseAsync()
                            .then((response) => {
                                if (!response.success) {
                                    console.error('获取星穹铁道体力数据失败: ' + response.message)
                                    if (!response.success) {
                                        console.error('获取星穹铁道体力数据失败: ' + response.message)
                                        let formData = {
                                            uid: config.selected_account.genshin_impact.selected_role.uid,
                                            loaded: false,
                                            message: response.message
                                        }
                                        let formInfo = formBindingData.createFormBindingData(formData)

                                        formProvider.updateForm(formId, formInfo)
                                            .then((data) => {
                                                console.info('FormAbility updateForm success.' + JSON.stringify(data));
                                            }).catch((error) => {
                                            console.error('FormAbility updateForm failed: ' + JSON.stringify(error));
                                        })
                                        return null
                                    }
                                    return null
                                }
                                console.warn('获取星穹铁道体力数据成功')

                                let json = JSON.parse(response.data)
                                let noteData: HSR_NoteInfo = new HSR_NoteInfo(json)

                                let formData = {
                                    uid: config.selected_account.genshin_impact.selected_role.uid,
                                    loaded: true,
                                    ...noteData.toJSON()
                                }

                                let formInfo = formBindingData.createFormBindingData(formData)

                                formProvider.updateForm(formId, formInfo)
                                    .then((data) => {
                                        console.info('FormAbility updateForm success.' + JSON.stringify(data));
                                    }).catch((error) => {
                                    console.error('FormAbility updateForm failed: ' + JSON.stringify(error));
                                })
                            })

                        break
                    }
                }
            } catch (err) {
                console.error('读取config配置错误 code: ' + err.code)
            }
        }
    }

    onRemoveForm(formId) {
        // Called to notify the form provider that a specified form has been destroyed.
        console.warn('onRemoveForm')
        let storeDB = dataStorage.getStorageSync(this.context.filesDir + 'FormStore')
        storeDB.deleteSync(`${formId}-name`);
    }

    onAcquireFormState(want) {
        // Called to return a {@link FormState} object.
        return formInfo.FormState.READY;
    }
};