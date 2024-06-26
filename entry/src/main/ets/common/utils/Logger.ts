/**
 * @FileName: Logger
 * @Author: Administrator
 * @Date: 2023/5/22 20:57
 * Description:
 */

import hilog from '@ohos.hilog';

class Logger {
    private domain: number;
    private prefix: string;

    // format Indicates the log format string.
    private format: string = '%{public}s';

    /**
     * constructor.
     *
     * @param prefix Identifies the log tag.
     * @param domain Indicates the service domain, which is a hexadecimal integer ranging from 0x0 to 0xFFFFF
     * @param args Indicates the log parameters.
     */
    constructor(prefix: string = '', domain: number = 0xFF00) {
        this.prefix = prefix;
        this.domain = domain;
    }

    debug(...args: any[]): void {
        hilog.debug(this.domain, this.prefix, this.format, args);
    }

    info(...args: any[]): void {
        hilog.info(this.domain, this.prefix, this.format, args);
    }

    warn(...args: any[]): void {
        hilog.warn(this.domain, this.prefix, this.format, args);
    }

    error(...args: any[]): void {
        hilog.error(this.domain, this.prefix, this.format, args);
    }
}

export default Logger;