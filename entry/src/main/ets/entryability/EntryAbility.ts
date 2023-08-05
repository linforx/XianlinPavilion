import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';

export default class EntryAbility extends UIAbility {
    onCreate(want, launchParam) {
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    }

    onDestroy() {
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
    }

    onWindowStageCreate(windowStage: window.WindowStage) {
        // Main window is created, set main page for this ability
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

        let windowClass: window.Window = null;
        try {
            window.getLastWindow(this.context, (err, data) => {
                if (err.code) {
                    console.error('Failed to obtain the top window. Cause: ' + JSON.stringify(err));
                    return;
                }
                windowClass = data;
                console.info('Succeeded in obtaining the top window. Data: ' + JSON.stringify(data));
                // 获取状态栏尺寸信息
                let type = window.AvoidAreaType.TYPE_SYSTEM;
                try {
                    let avoidArea = windowClass.getWindowAvoidArea(type);
                    globalThis.avoidArea = avoidArea

                    console.warn("avoidArea: " + JSON.stringify(globalThis.avoidArea))
                } catch (exception) {
                    console.error('Failed to obtain the area. Cause:' + JSON.stringify(exception));
                }
                // 设置窗口沉浸
                let isLayoutFullScreen= true;
                try {
                    windowClass.setWindowLayoutFullScreen(isLayoutFullScreen, (err) => {
                        if (err.code) {
                            console.error('Failed to set the window layout to full-screen mode. Cause:' + JSON.stringify(err));
                            return;
                        }
                        console.info('Succeeded in setting the window layout to full-screen mode.');
                    });
                    // 加载起始页
                    windowStage.loadContent('pages/Start', (err, data) => {
                        if (err.code) {
                            hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
                            return;
                        }
                        hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
                    });
                } catch (exception) {
                    console.error('Failed to set the window layout to full-screen mode. Cause:' + JSON.stringify(exception));
                }
            });
        } catch (exception) {
            console.error('Failed to obtain the top window. Cause: ' + JSON.stringify(exception));
        }
    }

    onWindowStageDestroy() {
        // Main window is destroyed, release UI related resources
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
    }

    onForeground() {
        // Ability has brought to foreground
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
    }

    onBackground() {
        // Ability has back to background
        hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
    }
}
