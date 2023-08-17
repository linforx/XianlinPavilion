import common from '@ohos.app.ability.common'
import fs from '@ohos.file.fs'
import util from '@ohos.util'

export default class FileManager {
    private context: common.Context
    private _filesDir: string

    constructor(context: common.Context) {
        this.context = context
        this._filesDir = context.filesDir
    }

    public get baseDir(): string {
        return this._filesDir
    }

    // 在指定目录下创建一个文件夹
    public mkdir(dirName: string, path: string = this._filesDir) {
        fs.mkdirSync(path + dirName)
    }

    // 删除指定目录的文件夹
    public rmdir(dirName: string, path: string = this._filesDir) {
        fs.rmdirSync(path + dirName)
    }

    // 在指定位置创建一个文件
    public createFile(filePath: string) {
        let file = fs.openSync(this._filesDir + filePath, fs.OpenMode.CREATE)
        fs.closeSync(file)
    }

    // 以指定模式打开文件
    public openFile(filePath: string, openMode: number): fs.File {
        let file = fs.openSync(this._filesDir + filePath, openMode)

        return file
    }

    // 对指定的文件进行字符串读取
    public readText(filePath: string): string {
        let content = fs.readTextSync(this._filesDir + filePath)

        return content
    }

    public writeText(file: fs.File, content: string): number
    public writeText(filePath: string, content: string): number

    // 对文件进行字符串写入
    public writeText(arg1: fs.File | string, content: string): number {
        let file: fs.File = null
        if (typeof arg1 === 'string') {
            file = this.openFile(arg1, fs.OpenMode.WRITE_ONLY | fs.OpenMode.CREATE)
        }
        else {
            file = arg1
        }
        let writeLen = fs.writeSync(file.fd, content)

        return writeLen
    }

    public closeFile(file: fs.File) {
        fs.closeSync(file)
    }

    // 查看当前目录下的文件目录
    public getFileList(filePath: string, options) {
        let files = fs.listFileSync(this._filesDir + filePath, options)

        return files
    }

    public async getRawFileTextAsync(path: string, encoding: string = 'utf-8') {
        try {
            let value = await this.context.resourceManager.getRawFileContent(path)
            let decoder = util.TextDecoder.create(encoding, { ignoreBOM : true })
            let retStr = decoder.decodeWithStream( value , {stream: false})

            return retStr
        } catch (error) {
            throw('getRawFileTextAsync error: ' + path + ' ' + error.message)
        }
    }
}