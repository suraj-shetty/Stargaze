//
//  SGAPIEndPoint.swift
//  StarGaze
//
//  Created by Suraj Shetty on 15/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case connect = "CONNECT"
    case options = "OPTIONS"
    case trace = "TRACE"
    case patch = "PATCH"
}

protocol SGAPIEndPoint {
    var url: String { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var headers: [String: Any]? { get }
    var body: [String: Any]? { get }    
}

//extension SGAPIEndPoint {
//    // a default extension that creates the full URL
//    var url: String {
//        return baseURL + path
//    }
//}
