//
//  IGFileManager.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 7/5/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
class IGFilesManager {
    enum Error: Swift.Error {
        case fileAlreadyExists
        case invalidDirectory
        case writtingFailed
        case fileNotExists
        case readingFailed
    }
    let fileManager: FileManager
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    func findAndRemove(token: String) {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            for fileURL in fileURLs {
                if fileURL.absoluteString.contains(token) {
                    try FileManager.default.removeItem(at: fileURL)
                }
            }
        } catch  { print(error) }
        print(FileManager.default.urls(for: .documentDirectory))

    }
    
    func makeLocalPath(_ type: FilePathType,nameOfFile: String) -> String {
        
        var filePath = ""
        let filename = nameOfFile
        
        switch type {
        case .thumb:
            IGFile().baseFilePathTypeRaw = BaseFilePathType.cache.rawValue
            filePath = IGGlobal.THUMB_DIR + "/" + filename + "jpg"
            break
        case .image:
            IGFile().baseFilePathTypeRaw = BaseFilePathType.document.rawValue
            filePath = IGGlobal.IMAGE_DIR + "/" + filename
            break
        case .video:
            IGFile().baseFilePathTypeRaw = BaseFilePathType.document.rawValue
            filePath = IGGlobal.VIDEO_DIR + "/" + filename
            break
        case .gif:
            IGFile().baseFilePathTypeRaw = BaseFilePathType.document.rawValue
            filePath = IGGlobal.GIF_DIR + "/" + filename
            break
        case .audio:
            IGFile().baseFilePathTypeRaw = BaseFilePathType.document.rawValue
            filePath = IGGlobal.AUDIO_DIR + "/" + filename
            break
        case .voice:
            IGFile().baseFilePathTypeRaw = BaseFilePathType.document.rawValue
            filePath = IGGlobal.VOICE_DIR + "/" + filename // use 'm4a' extension to be able to play voice
            break
        case .file:
            IGFile().baseFilePathTypeRaw = BaseFilePathType.document.rawValue
            filePath = IGGlobal.FILE_DIR + "/" + filename
            break
        case .avatar:
            IGFile().baseFilePathTypeRaw = BaseFilePathType.cache.rawValue
            filePath = IGGlobal.AVATAR_DIR + "/" + filename
            break
        case .sticker:
            IGFile().baseFilePathTypeRaw = BaseFilePathType.cache.rawValue
            filePath = IGGlobal.STICKER_DIR + "/" + filename
            break
        case .background:
            IGFile().baseFilePathTypeRaw = BaseFilePathType.cache.rawValue
            filePath = IGGlobal.BACKGROUND_DIR + "/" + filename
            break
        case .temp:
            IGFile().baseFilePathTypeRaw = BaseFilePathType.temp.rawValue
            filePath = IGGlobal.TEMP_DIR + "/" + filename
            break
        default:
            IGFile().baseFilePathTypeRaw = BaseFilePathType.temp.rawValue
            filePath = IGGlobal.TEMP_DIR + "/" + filename
            break
        }
        
        return filePath
    }
    func save(fileNamed: String, data: Data ) throws {
//        let newname = makeLocalPath(type,nameOfFile: fileNamed)
        guard let url = makeURL(forFileNamed: fileNamed) else {
            throw Error.invalidDirectory
        }
        if fileManager.fileExists(atPath: url.absoluteString) {
            throw Error.fileAlreadyExists
        }
        do {
            print("URL OF CHUNK :",url)
            if let outputStream = OutputStream(url: url, append: true) {
                outputStream.open()
                let bytesWritten = outputStream.write(data.bytes, maxLength: data.count)
                if bytesWritten < 0 {
                    print("write failure")
                }
                outputStream.close()
            } else {
                print("unable to open file")
            }
            
        } catch {
            debugPrint(error)
            throw Error.writtingFailed
        }
    }
    private func makeURL(forFileNamed fileName: String) -> URL? {
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return url.appendingPathComponent(fileName)
    }
    func findFile(forFileNamed fileName: String)  throws -> [Data : URL]? {
        guard let url = makeURL(forFileNamed: fileName) else {
            throw Error.invalidDirectory
        }
        guard fileManager.fileExists(atPath: url.path) else {
            throw Error.fileNotExists
        }
        do {
            return try [Data(contentsOf: url) : url]
        } catch {
            debugPrint(error)
            throw Error.readingFailed
        }
    }
    func read(fileNamed: String) throws -> [URL: Data] {
        guard let url = makeURL(forFileNamed: fileNamed) else {
            throw Error.invalidDirectory
        }
        print("FILES",FileManager.default.urls(for: .documentDirectory) ?? "none")

        guard fileManager.fileExists(atPath: url.path) else {
            throw Error.fileNotExists
        }
        do {
            print("URL OF IMAGE :",url)
            return try [url: Data(contentsOf: url)]
        } catch {
            debugPrint(error)
            throw Error.readingFailed
        }
    }
}
extension FileManager {
    func urls(for directory: FileManager.SearchPathDirectory, skipsHiddenFiles: Bool = true ) -> [URL]? {
        let documentsURL = urls(for: directory, in: .userDomainMask)[0]
        let fileURLs = try? contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
        return fileURLs
    }
}
