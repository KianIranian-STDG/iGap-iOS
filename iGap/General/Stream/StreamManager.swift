//
//  UploadStream.swift
//  iGap
//
//  Created by ahmad mohammadi on 6/28/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import CryptoSwift
import RxSwift
import RxCocoa

protocol StreamManagerDelegate {
    func uploadStatusDidChange(task: IGUploadTask, status: UploadDownloadStatus)
}

class StreamManager: NSObject, URLSessionTaskDelegate, StreamDelegate {
    
    var progress = PublishSubject<Double>()
    
    var delegate: StreamManagerDelegate?
    
    private var uploadTask: IGUploadTask
    
    private lazy var session: URLSession = URLSession(configuration: .default,
    delegate: self,
    delegateQueue: .main)
    
    private let bufferSize = 4096
    
    private lazy var boundStreams: Streams? = {
        
        var inputOrNil: InputStream? = nil
        var outputOrNil: OutputStream? = nil
        Stream.getBoundStreams(withBufferSize: self.bufferSize,
                               inputStream: &inputOrNil,
                               outputStream: &outputOrNil)
        
        guard let input = inputOrNil, let output = outputOrNil else {
            fatalError("On return of `getBoundStreams`, both `inputStream` and `outputStream` will contain non-nil streams.")
        }
        // configure and open output stream
        output.delegate = self
        input.delegate = self
        output.schedule(in: .current, forMode: .default)
        output.open()
        return Streams(input: input, output: output)
    }()
    
    private var fileHandler = FileHandle()
    private var encryptor : (Cryptor & Updatable)?
    private var isFirstChunk = true
    private var currentOffset: UInt64 = 0
    private var totalFileSize: Int64 = 0
    private var streamUploadTask = URLSessionUploadTask()
    
    init(uploadTask: IGUploadTask) {
        self.uploadTask = uploadTask
        super.init()
    }
    
    func createUploadTask(token: String, path: URL, offset: UInt64 = 0) {
        
        let url = URL(string: "http://192.168.10.31:3007/v1.0/upload/\(token)")!
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 10)
        fileHandler = try! FileHandle(forReadingFrom: path)
        currentOffset = offset
        
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: path.path)
            totalFileSize = attr[FileAttributeKey.size] as! Int64
        } catch {
            delegate?.uploadStatusDidChange(task: uploadTask, status: .failed)
            return
        }
        
        request.allHTTPHeaderFields = ["Authorization": "Bearer " + IGAppManager.sharedManager.getAccessToken()!]
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
        request.httpBodyStream = boundStreams?.input
        request.httpMethod = "POST"
        streamUploadTask = session.uploadTask(withStreamedRequest: request)
        
        streamUploadTask.resume()
        
        let ivString = IGSecurityManager.sharedManager.generateIVString()
        boundStreams?.output.write((ivString.data(using: .utf8)!.bytes), maxLength: 16)

        encryptor = try! IGSecurityManager.sharedManager.generateEncryptor(iv: ivString)
        
        
        
    }
    
    
    
    internal func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        completionHandler(boundStreams?.input)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        progress.onNext(Double(totalBytesSent)/Double(totalFileSize))
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if error == nil {
            delegate?.uploadStatusDidChange(task: uploadTask, status: .finished)
            return
        }
        
        delegate?.uploadStatusDidChange(task: uploadTask, status: .failed)
        streamUploadTask.cancel()
        
    }
    
    internal func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if eventCode.contains(.hasSpaceAvailable) {
            
            if (aStream == self.boundStreams?.output){
            
                fileHandler.seek(toFileOffset: currentOffset)
                var length = bufferSize
                if isFirstChunk {
                    length = bufferSize - 16
                    isFirstChunk = false
                }
                
                let dt = fileHandler.readData(ofLength: length)
                currentOffset += UInt64(length)
                
                
                if dt.count <= 0 {
                    
                    try! encryptor?.finish(output: {[weak self] (bytes) in
                        guard let sSelf = self else {
                            return
                        }

                        sSelf.boundStreams?.output.write(bytes, maxLength: bytes.count)

                    })
                    
                    boundStreams?.output.close()
                    return
                }
                                
                try! encryptor?.update(withBytes: dt.bytes, output: {[weak self] (bytes) in

                    guard let sSelf = self else {
                        return
                    }
                    
                    sSelf.boundStreams?.output.write(bytes, maxLength: bytes.count)

                })
                
            }
            
        }
        
        if eventCode.contains(.hasBytesAvailable) {
            
            var buffer = Array<UInt8>(repeating: 0, count: bufferSize)
            if (aStream == self.boundStreams?.input){

                while (self.boundStreams!.input.hasBytesAvailable) {
                    
                    let len = self.boundStreams!.input.read(&buffer, maxLength: buffer.count)

                    if len <= 0 {
                        self.boundStreams?.input.close()
                    }

                }
            }
            
        }
        
    }
    
}

fileprivate struct Streams {
    let input: InputStream
    let output: OutputStream
}
