//
//  HTTPClient.swift
//  StarGaze
//
//  Created by Suraj Sukumar Shetty on 01/10/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation


protocol HTTPClient {
    func sendRequest<T: Decodable>(endpoint: SGAPIEndPoint, responseModel: T.Type) async -> Result<T, SGAPIError>
}

extension HTTPClient {
    func sendRequest<T: Decodable>(
        endpoint: SGAPIEndPoint,
        responseModel: T.Type
    ) async -> Result<T, SGAPIError> {
        
        guard var url = URL(string: endpoint.url + endpoint.path) else {
            return .failure(.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.httpMethod.rawValue
        
        endpoint.headers?.forEach({ header in
            request.setValue(header.value as? String, forHTTPHeaderField: header.key)
        })
                        
        if let body = endpoint.body {
            switch endpoint.httpMethod {
            case .get:
                let queryParams = body.map({ URLQueryItem(name: $0, value: String(describing: $1))})
                
                var urlComponents = URLComponents(string: url.absoluteString)
                urlComponents?.queryItems = queryParams
                
                url = (urlComponents?.url)!
                request.url = url
                
            default:
                request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
            }
        }
        
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request, delegate: nil)
            guard let response = response as? HTTPURLResponse else {
                return .failure(.invalidResponse)
            }
            switch response.statusCode {
            case 200...299:
                let serverFormatter = DateFormatter()
                serverFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                
//#if DEBUG
//if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
//   let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
//    print(String(decoding: jsonData, as: UTF8.self))
//}
//#endif
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(serverFormatter)
                
                guard let decodedResponse = try? decoder.decode(responseModel, from: data) else {
                    if let errorResponse = try? decoder.decode(ErrorResponse.self,
                                                               from: data) {
                        let detail = errorResponse.error
                        if let msg = detail.info?.first?.msg ?? detail.errors.first, !msg.isEmpty {
                            return .failure(.custom(msg))
                        }
                        else {
                            return .failure(.statusCode(detail.code))
                        }
                    }
                    else {
                        return .failure(.invalidJSON)
                    }
                }
                return .success(decodedResponse)
            case 401:
                return .failure(.unauthorized)
            default:
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self,
                                                                 from: data) {
                    let detail = errorResponse.error
                    if let msg = detail.info?.first?.msg ?? detail.errors.first, !msg.isEmpty {
                        return .failure(.custom(msg))
                    }
                    else {
                        return .failure(.statusCode(detail.code))
                    }
                }
                else {
                    return .failure(.statusCode(response.statusCode))
                }
            }
        } catch {
            print("\(error)")
            return .failure(.unknown)
        }
    }
}
