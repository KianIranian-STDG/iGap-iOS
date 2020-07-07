//
//  UploadStream.swift
//  iGap
//
//  Created by ahmad mohammadi on 6/28/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CryptoSwift

class UploadStream: NSObject, URLSessionTaskDelegate, StreamDelegate {
    
    private var canWrite = true
    
    
    lazy var session: URLSession = URLSession(configuration: .default,
    delegate: self,
    delegateQueue: .main)
    
    lazy var boundStreams: Streams? = {
        
        var inputOrNil: InputStream? = nil
        var outputOrNil: OutputStream? = nil
        Stream.getBoundStreams(withBufferSize: 256,
                               inputStream: &inputOrNil,
                               outputStream: &outputOrNil)
        
        guard let input = inputOrNil, let output = outputOrNil else {
            fatalError("On return of `getBoundStreams`, both `inputStream` and `outputStream` will contain non-nil streams.")
        }
        // configure and open output stream
        output.delegate = self
        output.schedule(in: .current, forMode: .default)
        output.open()
        return Streams(input: input, output: output)
    }()
    
    private var fileSize: UInt64 = 0
    private var encryptedFileSize: UInt64 = 0
    private var rickPath = String()
    private var fileHandler = FileHandle()
    
    private var iv = Data()
    
    
    
//    func getToken() {
//        
//        someApi.shared.getToken {[weak self] (token) in
//            guard let sSelf = self else {
//                return
//            }
//            sSelf.createUploadTask(token: token)
//        }
//        
//        
//    }
    
    private var ivString = String()
    private var encryptor : (Cryptor & Updatable)?
    
    func createUploadTask(token: String = "") {
        
        iv = IGSecurityManager.sharedManager.generateIV()
        
//        let img = UIImage(named: "2")!
//        let data = img.pngData()!
        
//        guard let rickPath = Bundle.main.path(forResource: "rick", ofType:"mkv") else {
//            debugPrint("video.m4v not found")
//            return
//        }
        
        if let path = Bundle.main.path(forResource: "x", ofType:"png") {
            rickPath = path
        }else {
            return
        }
        
        do {
                    //return [FileAttributeKey : Any]
            let attr = try FileManager.default.attributesOfItem(atPath: rickPath)
            fileSize = attr[FileAttributeKey.size] as! UInt64

//            //if you convert to NSDictionary, you can get file size old way as well.
//            let dict = attr as NSDictionary
//            fileSize = dict.fileSize()
        } catch {
            print("Error: \(error)")
        }
        
        
        let url = URL(string: "http://192.168.8.15:3010/v1.0/Dec/\(token)")!
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 50)
        fileHandler = try! FileHandle(forReadingFrom: URL(fileURLWithPath: rickPath))
        
//        let userId = IGRegisteredUser.getUserIdWithPhone(phone: "989353581377")
        
//        eofIndex = fileHandler.
        
//        let encryptedData = encryptData(data: data)
        
//        ((file.length() / 16 + 1) * 16) + 16;
        
        
//        encryptedFileSize = fileSize + 32 //((fileSize / 16 + 1) * 16) + 16
        
        
            // Write to data to stream
//        guard let messageData = message.data(using: .utf8) else { return }
//        let messageCount = messageData.count
//        let bytesWritten: Int = messageData.withUnsafeBytes() { (buffer: UnsafePointer<UInt8>) in
//            self.canWrite = false
//            return self.boundStreams.output.write(buffer, maxLength: messageCount)
//        }
        
        
//        while(0<encSymmetricKeyData.count){
//            let chunk = encSymmetricKeyData.subdata(in: 0..<secondaryChunkSize)
//            let clear = ClearMessageLocal(data: chunk)
//            let encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
//            encryptedSymmetricKeyData.append(contentsOf: encrypted.data)
//            encSymmetricKeyData = encSymmetricKeyData.subdata(in: secondaryChunkSize..<encSymmetricKeyData.count)
//        }
        
        
        
        
        request.allHTTPHeaderFields = ["Authorization": "Bearer " + IGAppManager.sharedManager.getAccessToken()!]
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
//        request.setValue("Keep-Alive", forHTTPHeaderField: "timeout=50, max=10000000")
//        request.addValue(String(fileSize), forHTTPHeaderField: "Content-Length") // <-- here!
//        request.httpBodyStream = InputStream(data: encryptData(data: data))
//        request.httpBodyStream = InputStream(fileAtPath: rickPath)
        request.httpBodyStream = boundStreams?.input
//        print("=-=-=-=-=-", boundStreams.input)
        request.httpMethod = "POST"
        let uploadTask = session.uploadTask(withStreamedRequest: request)
        
        
        
        uploadTask.resume()
        
        
        ivString = IGSecurityManager.sharedManager.generateIVString()
        
        let data = Data(ivString.utf8)
        let hexString = data.map{ String(format:"%02x", $0) }.joined()
        print("=-=-=-=-=-IV1: ", hexString)
        
        encryptor = try! IGSecurityManager.sharedManager.generateEncryptor(iv: ivString)
        
        
        
        
//        do {
//            // write until all is written
//            func writeTo(stream: OutputStream, bytes: Array<UInt8>) {
//                var writtenCount = 0
//                while stream.hasSpaceAvailable && writtenCount < bytes.count {
//                    writtenCount += stream.write(bytes, maxLength: bytes.count)
//                }
//            }
////            let path = "somewhere"
////            let aes = try AES(key: key, iv: iv)
////            var encryptor = aes.makeEncryptor()
//
//            // prepare streams
//            //let data = Data(bytes: (0..<100).map { $0 })
////            let inputStream = InputStream(fileAtPath: path)
//            let inputStream = InputStream(fileAtPath: rickPath)
////            let outputStream = OutputStream(toFileAtPath: "somewhere", append: false)
//            inputStream?.open()
//            boundStreams?.output.open()  //outputStream?.open()
//
//            var buffer = Array<UInt8>(repeating: 0, count: 2)
//
//            // encrypt input stream data and write encrypted result to output stream
//            while (inputStream?.hasBytesAvailable)! {
//                let readCount = inputStream?.read(&buffer, maxLength: buffer.count)
//                if (readCount! > 0) {
//                    try encryptor!.update(withBytes: buffer[0..<readCount!]) { (bytes) in
//                        writeTo(stream: boundStreams!.output, bytes: bytes)
//                    }
//                }
//            }
//
//            // finalize encryption
//            try encryptor!.finish { (bytes) in
//                writeTo(stream: boundStreams!.output, bytes: bytes)
//            }
//
//            if let ciphertext = boundStreams?.output.property(forKey: Stream.PropertyKey(rawValue: Stream.PropertyKey.dataWrittenToMemoryStreamKey.rawValue)) as? Data {
//                print("Encrypted stream data: \(ciphertext.toHexString())")
//            }
//
//        } catch {
//            print(error)
//        }
        
        
        
        
    }
    
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        completionHandler(boundStreams?.input)
    }
    
    private var shouldEnd = false
    private var isFirstChunk = true
    var currentOffset: UInt64 = 0
//    var eofIndex: UInt64 = 0
    
    let pip = Pipe()
    
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        
        
        guard aStream == boundStreams?.output else {
            return
        }
        if eventCode.contains(.hasSpaceAvailable) {
            
//            return
            
            
            pip.fileHandleForReading
            
            
            
            
            return
            
            if !canWrite {
                return
            }
            
            var dt = Data()
                
            print("=-=-=-=-=-++++", fileSize)
            print("=-=-=-=-=-++++", currentOffset)
            
            fileHandler.seek(toFileOffset: currentOffset)
            dt = fileHandler.readData(ofLength: 256)
            currentOffset += 256
//            }
            
            if dt.count <= 0 {
                canWrite = false
                return
            }
            
                
            print("=-=-=-=-=-TTT11111: ", String(currentOffset).inRialFormat())
            print("=-=-=-=-=-TTT22222: ", dt.count)
                
            try! encryptor?.update(withBytes: dt.bytes, isLast: false, output: { (bytes) in
                print("=-=-=-=-=-=- XXXX1: ", bytes)
                print("=-=-=-=-=-=- XXXX2: ", bytes.count)
                var finalByte = bytes
                if isFirstChunk {
                    finalByte = (ivString.data(using: .utf8)!.bytes) + bytes
                    isFirstChunk = false
                }
                self.boundStreams?.output.write(finalByte, maxLength: finalByte.count)
            })
            
            
            if currentOffset + 256 > fileSize {
                try! encryptor!.finish { (bytes) in
//                  writeTo(stream: outputStream, bytes: bytes)
                    print("=-=-=-=-=-=- TTTT11: ", bytes)
                    print("=-=-=-=-=-=- TTTT22: ", bytes.count)
                    self.boundStreams?.output.write(bytes, maxLength: bytes.count)
                }
            }
            
            
            print("fileSize : \(fileSize)  ***  currentOffset: \(currentOffset)")
            if shouldEnd {
                print("=-=-=-=-=-=-Closed Stream")
//                boundStreams?.output.close()
//                boundStreams?.input.close()
//                canWrite = false
//                return
            }
            
        }
            
        
        if eventCode.contains(.errorOccurred) {
            // Close the streams and alert the user that the upload failed.
            print("-=-=-=-=-=-=-=- Stream Error")
            boundStreams?.output.close()
            boundStreams?.input.close()
            
            boundStreams = nil
            
        }
        
        if eventCode.contains(.endEncountered) {
            print("=-=--=-==-=-=-=-=- End eeeee =-=-=-=-=-=-=-=-")
//            _ = try! encryptor!.finish()
//            boundStreams?.output.close()
        }
        
    }
    
    private func encryptData(data: Data, addIv: Bool) -> Data {
        return IGSecurityManager.sharedManager.encryptAndAddIV(payload: data, addIv: true)
//        return IGSecurityManager.sharedManager.encryptAndAddIV(payload: data, iv: iv, addIv: addIv)
    }
    
}

struct Streams {
    let input: InputStream
    let output: OutputStream
}

typealias getToken = (_ token: String) -> Void

class someApi {
    
    static let shared = someApi()
    
    private func getHeader() -> HTTPHeaders {
        if IGApiBase.httpHeaders == nil {
            guard let token = IGAppManager.sharedManager.getAccessToken() else { return ["Authorization": ""] }
            let authorization = "Bearer " + token
            let contentType = "application/json"
            IGApiBase.httpHeaders = ["Authorization": authorization, "Content-Type": contentType]
        }
        return IGApiBase.httpHeaders
    }
    
    func getToken(completion: @escaping getToken) {
        
        let url = URL(string: "http://192.168.8.15:4000/v1.0/init")!
        
        let params: Parameters = ["size": 5341748,
                                  "name": "rec.mov",
                                  "extension": "mov",
                                  "room_id": "12"]
        
        print("=-=-=-=- Token Called =-=-=-=-")
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: self.getHeader()).response {[weak self] (response) in
            guard let sSelf = self else {
                return
            }
            
            print("=-=-=-=-=-", response.response)
            
            let responseData = try! JSON(data: response.data!)
            let token = responseData["token"].string ?? ""
//            sSelf.createUploadTask(token: token)
            
            completion(token)
            
            
        }
        
    }
    
}

