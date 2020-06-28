//
//  UploadStream.swift
//  iGap
//
//  Created by ahmad mohammadi on 6/28/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

class UploadStream: NSObject, URLSessionTaskDelegate, StreamDelegate {
    
    private var canWrite = true
    
    lazy var session: URLSession = URLSession(configuration: .default,
    delegate: self,
    delegateQueue: .main)
    
    lazy var boundStreams: Streams = {
        
        var inputOrNil: InputStream? = nil
        var outputOrNil: OutputStream? = nil
        Stream.getBoundStreams(withBufferSize: 4096,
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
    
    func createUploadTask() {
        
        let img = UIImage(named: "2")!
        let data = img.pngData()!
        
        let url = URL(string: "http://192.168.8.15:4000/v2.0/upload/7fac9a10-6d3e-4fb3-aedc-bdda0377fbac")!
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalCacheData,
                                 timeoutInterval: 10)
        
        let userId = IGRegisteredUser.getUserIdWithPhone(phone: "989353581377")
        request.allHTTPHeaderFields = ["Authorization": "Bearer " + IGAppManager.sharedManager.getAccessToken()!,
                                       "userid": String(userId!)]
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.addValue(String(data.count), forHTTPHeaderField: "Content-Length") // <-- here!
        request.httpBodyStream = InputStream(data: data)
        request.httpMethod = "POST"
        let uploadTask = session.uploadTask(withStreamedRequest: request)
        uploadTask.resume()
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask,
                    needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        completionHandler(boundStreams.input)
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        guard aStream == boundStreams.output else {
            return
        }
        if eventCode.contains(.hasSpaceAvailable) {
            canWrite = true
        }
        if eventCode.contains(.errorOccurred) {
            // Close the streams and alert the user that the upload failed.
        }
    }
    
}

struct Streams {
    let input: InputStream
    let output: OutputStream
}
