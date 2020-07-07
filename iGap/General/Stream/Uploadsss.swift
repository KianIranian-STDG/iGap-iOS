//
//  Uploadsss.swift
//  iGap
//
//  Created by ahmad mohammadi on 7/7/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation


class NetworkManager : NSObject, URLSessionDataDelegate, StreamDelegate {

    static var shared = NetworkManager()

    private var session: URLSession! = nil

    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: .main)
    }

    private var streamingTask: URLSessionDataTask? = nil

    var isStreaming: Bool { return self.streamingTask != nil }

    func startStreaming() {
        precondition( !self.isStreaming )

        let url = URL(string: "http://192.168.8.15:3010/v1.0/Dec/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let task = self.session.uploadTask(withStreamedRequest: request)
        self.streamingTask = task
        task.resume()
    }

    func stopStreaming() {
        guard let task = self.streamingTask else {
            return
        }
        self.streamingTask = nil
        task.cancel()
        self.closeStream()
    }

    var outputStream: OutputStream? = nil

    private func closeStream() {
        if let stream = self.outputStream {
            stream.close()
            self.outputStream = nil
        }
    }

    var inStream: InputStream? = nil
    var outStream: OutputStream? = nil
    
    func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
//        self.closeStream()
        
//        outputStream?.delegate = self
        Stream.getBoundStreams(withBufferSize: 4096, inputStream: &inStream, outputStream: &outStream)
        
        self.outputStream = outStream

        completionHandler(inStream)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        NSLog("task data: %@", data as NSData)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error as NSError? {
            NSLog("task error: %@ / %d", error.domain, error.code)
        } else {
            NSLog("task complete")
        }
    }
    
    var currentOffset: UInt64 = 0
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        
        if eventCode.contains(.hasSpaceAvailable) {
            
            
            var fileHandler = FileHandle()
            fileHandler.seek(toFileOffset: currentOffset)
            let dt = fileHandler.readData(ofLength: 4096)
            currentOffset += 4096
                        
//            if dt.count <= 0 {
//                canWrite = false
//                boundStreams?.output.close()
//                boundStreams?.input.close()
//                return
//            }
                            
            print("=-=-=-=-=-TTT11111: ", String(currentOffset).inRialFormat())
            print("=-=-=-=-=-TTT22222: ", dt.count)
            
            self.outStream?.write(dt.bytes, maxLength: dt.count)
            
        }
        
    }
    
    
}
