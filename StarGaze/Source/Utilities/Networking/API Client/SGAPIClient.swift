//
//  SGAPIClient.swift
//  StarGaze
//
//  Created by Suraj Shetty on 15/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation
import Combine

struct SGApiClient {
    static let shared = SGApiClient()
    
    struct Response<T> {
           let value: T
           let response: URLResponse
       }
    
    
//    private let uploadManager = WOUploadManager()
    
    func run<T: Decodable>(_ endPoint: SGAPIEndPoint, queue:DispatchQueue = .main) -> AnyPublisher<Response<T>, SGAPIError> {
        guard let url = URL(string: endPoint.url + endPoint.path) else {
            return Fail(error: SGAPIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endPoint.httpMethod.rawValue
        
        endPoint.headers?.forEach({ header in
            request.setValue(header.value as? String, forHTTPHeaderField: header.key)
            })
        
        if let body = endPoint.body, body.isEmpty == false {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        
//        do {
//            if let body = endPoint.body, body.isEmpty == false {
//                let bodyData = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
//                request.httpBody = bodyData
//            }
//        }
//        catch {
//            debugPrint("Invalid JSON request body for \(endPoint.path). Body =\(endPoint.body!)")
//            return Fail(error: SGAPIError.invalidBody)
//                .eraseToAnyPublisher()
//        }
        
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> Response<T> in
//                #if DEBUG
//
//                if let json = try? JSONSerialization.jsonObject(with: result.data, options: .mutableContainers),
//                   let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
//                    print(String(decoding: jsonData, as: UTF8.self))
//                }
//                #endif
                
                let data = try validate(result.data, result.response)
                let value = try JSONDecoder().decode(T.self, from: data)
                return Response(value: value, response: result.response)
            }
            .mapError({ error in
                if let apiError = error as? SGAPIError {
                    return apiError
                }
                
                let statusCode = (error as NSError).code
                
                switch statusCode {
                case NSURLErrorCancelled:
                    return SGAPIError.cancelled
                    
                case NSURLErrorNotConnectedToInternet:
                    return SGAPIError.noNetwork
                    
                default:
                    return SGAPIError.statusCode(statusCode)
                }
            })
            .receive(on: queue)
            .eraseToAnyPublisher()
    }
    
    func boolRun(_ endPoint: SGAPIEndPoint, queue:DispatchQueue = .main) -> AnyPublisher<Bool, SGAPIError> {
        guard let url = URL(string: endPoint.url + endPoint.path) else {
            return Fail(error: SGAPIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        
        
        var request = URLRequest(url: url)
        request.httpMethod = endPoint.httpMethod.rawValue
        
        endPoint.headers?.forEach({ header in
            request.setValue(header.value as? String, forHTTPHeaderField: header.key)
            })
        
        if let body = endPoint.body, body.isEmpty == false {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
                                    
//            #if DEBUG
//
//            if let theJSONData = try? JSONSerialization.data(
//                withJSONObject: body,
//                options: []) {
//                let theJSONText = String(data: theJSONData,
//                                           encoding: .ascii)
//                debugPrint("Response")
//                print(theJSONText ?? "")
//            }
//
//            #endif
        }
        
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap({ result -> Bool in
//#if DEBUG
//                if let json = try? JSONSerialization.jsonObject(with: result.data, options: .mutableContainers),
//                   let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
//                    print(String(decoding: jsonData, as: UTF8.self))
//                }
//#endif
                _ = try validate(result.data, result.response)
                return true
            })
            .mapError({ error in
                if let apiError = error as? SGAPIError {
                    return apiError
                }
                
                let statusCode = (error as NSError).code
                
                switch statusCode {
                case NSURLErrorCancelled:
                    return SGAPIError.cancelled
                    
                case NSURLErrorNotConnectedToInternet:
                    return SGAPIError.noNetwork
                    
                default:
                    return SGAPIError.statusCode(statusCode)
                }
            })
            .receive(on: queue)
            .eraseToAnyPublisher()
    }
    
    func get<T: Decodable>(_ endPoint: SGAPIEndPoint, queue:DispatchQueue = .main) -> AnyPublisher<Response<T>, SGAPIError> {
        guard var url = URL(string: endPoint.url + endPoint.path) else {
            return Fail(error: SGAPIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        if let params = endPoint.body, params.isEmpty == false {
            let queryParams = params.map({ URLQueryItem(name: $0, value: String(describing: $1))})
            
            var urlComponents = URLComponents(string: url.absoluteString)
            urlComponents?.queryItems = queryParams
            
            url = (urlComponents?.url)!
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endPoint.httpMethod.rawValue
        
        endPoint.headers?.forEach({ header in
            request.setValue(header.value as? String, forHTTPHeaderField: header.key)
            })
        
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap { result -> Response<T> in
//                #if DEBUG
//                if let json = try? JSONSerialization.jsonObject(with: result.data, options: .mutableContainers),
//                   let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
//                    print(String(decoding: jsonData, as: UTF8.self))
//                }
//                #endif
                
                let serverFormatter = DateFormatter()
                serverFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(serverFormatter)
                
                let data = try validate(result.data, result.response)
                let value = try decoder.decode(T.self, from: data)
                return Response(value: value, response: result.response)
            }
            .mapError({ error in
                print("\(url)")
                if let apiError = error as? SGAPIError {
                    return apiError
                }
                
                let statusCode = (error as NSError).code
                
                switch statusCode {
                case NSURLErrorCancelled:
                    return SGAPIError.cancelled
                    
                case NSURLErrorNotConnectedToInternet:
                    return SGAPIError.noNetwork
                    
                default:
                    return SGAPIError.statusCode(statusCode)
                }
            })
            .receive(on: queue)
            .eraseToAnyPublisher()
    }
    
    
//    func upload(_ endPoint: APIEndPoint, jsonKey:String, files:[String], queue:DispatchQueue = .main) -> AnyPublisher<UploadResponse, Error> {
//
//        guard let url = URL(string: endPoint.url) else { fatalError("Invalid url \(endPoint.url)")}
//
//        var request = URLRequest(url: url)
//        request.httpMethod = endPoint.httpMethod.rawValue
//
//        endPoint.headers?.forEach({ header in
//            request.setValue(header.value as? String, forHTTPHeaderField: header.key)
//            })
//
//        let boundary = UUID().uuidString
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//
//        var body = Data()
//        let paramName = "files[]"
//        for (index, file) in files.enumerated() {
//            let fileURL = URL(fileURLWithPath: file)
//
//            do {
//                let data = try Data(contentsOf: fileURL)
//                let format = ImageFormat.get(from: data)
//                switch format {
//                case .unknown:
//                    continue
//
//                default:
//                    let fileName = "image\(index)"
//                    // Add the image data to the raw http request data
//                    body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
//                    body.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
//                    body.append("Content-Type: \(format.contentType)\r\n\r\n".data(using: .utf8)!)
//                    body.append(data)
//                    body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
//                }
//            }
//            catch {
//            }
//        }
//
//        if let requestBody = endPoint.body {
//            do {
//                let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted)
//
//                body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
//                body.append("Content-Disposition: form-data; name=\"\(jsonKey)\";\"\r\n".data(using: .utf8)!)
//                body.append("Content-Type: application/json;\r\n\r\n".data(using: .utf8)!)
//                body.append(jsonData)
//                body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
//            }
//            catch {
//
//            }
//        }
//
//        return self.uploadManager
//            .upload(request: request, data: body)
//            .receive(on: queue)
//            .eraseToAnyPublisher()
//
//
////        do {
////            if let body = endPoint.body, body.isEmpty == false {
////                let bodyData = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
////                request.httpBody = bodyData
////            }
////        }
////        catch {
////            debugPrint("Invalid JSON request body for \(endPoint.path). Body =\(endPoint.body!)")
////        }
//
//
//
//    }
 
    
    func validate(_ data: Data, _ response: URLResponse) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SGAPIError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            
            switch httpResponse.statusCode {
            case NSURLErrorCancelled:
                throw SGAPIError.cancelled
                
            case NSURLErrorNotConnectedToInternet:
                throw SGAPIError.noNetwork
                
            default:
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self,
                                                                 from: data) {
                    let detail = errorResponse.error
                    if let msg = detail.info?.first?.msg ?? detail.errors.first, !msg.isEmpty {
                        throw SGAPIError.custom(msg)
                    }
                    else {
                        throw SGAPIError.statusCode(detail.code)
                    }
                }
                else {
                    throw SGAPIError.statusCode(httpResponse.statusCode)
                }
            }
        }
        
        
        return data
    }
}
