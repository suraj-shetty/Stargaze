//
//  SGUploadManager.swift
//  StarGaze
//
//  Created by Suraj Shetty on 05/05/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit
import Combine

enum UploadResponse {
    case progress(percentage: Double)
    case response(result: SGUploadResult?)
}

class SGUploadManager: NSObject {
    static var shared: SGUploadManager = {
        return SGUploadManager()
    }()
    
    let progress: PassthroughSubject<(id: Int, progress: Double), Never> = .init()
    lazy var session: URLSession = {
        .init(configuration: .default, delegate: self, delegateQueue: nil)
    }()
    
    
    func upload(info:SGUploadInfo) -> AnyPublisher<SGUploadResult, SGAPIError> {
        
        var basePath:String = ""
        
        switch info.type {
        case .feed: basePath = URLEndPoints.socialBaseUrlString
        case .event: basePath = URLEndPoints.eventBaseUrlString
        case .profile: basePath = URLEndPoints.userBaseUrlString
        }
        
        guard basePath.isEmpty == false
        else { return Fail(error: SGAPIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        let uploadPath =  basePath + "shared/upload"
        
        guard let uploadURL = URL(string: uploadPath)
        else {
            return Fail(error: SGAPIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        guard let fileData = try? Data(contentsOf: info.fileURL), !fileData.isEmpty
        else {
            return Fail(error: SGAPIError.invalidBody)
                .eraseToAnyPublisher()
        }
                        
        let subject:PassthroughSubject<SGUploadResult, SGAPIError> = .init()
        
        let kBoundary = UUID().uuidString
        let contentType = "multipart/form-data; boundary=\(kBoundary)"
        let bodyData = createMultipartBody(data: fileData,
                                           fileName: info.fileURL.lastPathComponent,
                                           boundary: kBoundary,
                                           name: "file",
                                           mimeType: info.mimeType)

        var uploadRequest = URLRequest(url: uploadURL)
        uploadRequest.httpMethod = HTTPMethod.post.rawValue
        uploadRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        uploadRequest.setValue(String(bodyData.count), forHTTPHeaderField: "Content-Length")
        
        if let token = SGAppSession.shared.token, token.isEmpty == false {
            uploadRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        uploadRequest.httpBody = bodyData
        
            
#if DEBUG
let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB, .useMB] // optional: restricts the units to MB only
      bcf.countStyle = .file
      let string = bcf.string(fromByteCount: Int64(bodyData.count))
    print("Upload file size: \(string)")
#endif
                
        let task = session.dataTask(with: uploadRequest) { data, response, error in
            if let error = error {
                subject.send(completion: .failure(SGAPIError.custom(error.localizedDescription)))
                return
            }
            guard let response = response else {
                subject.send(completion: .failure(SGAPIError.invalidResponse))
                return
            }
            
            guard let data = data else {
                subject.send(completion: .failure(SGAPIError.emptyData))
                return
            }
            
            do {
#if DEBUG
                if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                   let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                    print(String(decoding: jsonData, as: UTF8.self))
                }
                else {
                    print((String(data: data, encoding: .utf8))!)
                }
#endif
                
                let jsonData = try self.validate(data, response)
                let result = try JSONDecoder().decode(SGUploadResponse.self, from: jsonData).result
                
                subject.send(result)
                subject.send(completion: .finished)
            }
            catch let error as SGAPIError {
                subject.send(completion: .failure(error))
            }
            
            catch {
                subject.send(completion: .failure(.invalidJSON))
            }
        }
                
        task.resume()
               
        return subject.eraseToAnyPublisher()
        
//        return progress
//            .filter{ $0.id == task.taskIdentifier }
//            .setFailureType(to: SGAPIError.self)
//            .map { .progress(percentage: $0.progress) }
//            .merge(with: subject)
//            .eraseToAnyPublisher()
    }
    
    private func validate(_ data: Data, _ response: URLResponse) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SGAPIError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == NSURLErrorCancelled {
                throw SGAPIError.cancelled
            }
            else {
                throw SGAPIError.statusCode(httpResponse.statusCode)
            }
        }
        
        
        return data
    }
    
    private func createMultipartBody(data:Data, fileName: String, boundary:String, name:String, mimeType:SGMimeType) -> Data {
        let body = NSMutableData()
        let lineBreak = "\r\n"
        let boundaryPrefix = "\r\n--\(boundary)\r\n"
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n")
        body.appendString("Content-Type: \(mimeType.rawValue)\r\n\r\n")
        body.append(data)
        body.appendString(lineBreak)
        body.appendString("--\(boundary)--")
        return body as Data
    }
}


extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

extension SGUploadManager: URLSessionTaskDelegate {
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
     ) {
        progress.send((
            id: task.taskIdentifier,
            progress: task.progress.fractionCompleted
        ))
     }
}
