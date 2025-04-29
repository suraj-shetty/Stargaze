//
//  Enums.swift
//  StarGaze
//
//  Created by Suraj Shetty on 18/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum SGAPIError: Error, Hashable, Identifiable {
    var id: Self { self }
    
    case invalidBody
    case invalidEndpoint
    case invalidURL
    case emptyData
    case invalidJSON
    case invalidResponse
    case statusCode(Int)
    case custom(String)
    case cancelled
    case noNetwork
    case unauthorized
    case unknown
}

extension SGAPIError: CustomStringConvertible {
    var description: String {
        switch self {
        case .invalidBody:          return "Invalid bady sent for the request"
        case .invalidEndpoint:      return "Invalid API End-point used for the call"
        case .invalidURL:           return "Invalid API End-point used"
        case .emptyData:            return "Empty response data received"
        case .invalidJSON:          return "Invalid JSON data received"
        case .invalidResponse:      return "Invalid response received"
        case .statusCode(let code): return "Status \(code) received for the call"
        case .custom(let msg):      return msg
        case .cancelled:            return "Called Cancelled"
        case .noNetwork:            return "Internet not available"
        case .unauthorized:         return "Unauthorized"
        case .unknown:              return "Unknown error occured"
        }
    }
}

extension SGAPIError: LocalizedError {
    var errorDescription: String? {
        return description
    }
}

enum SGFeedCategory: String, Codable {
    case generic = "0"
    case exclusive = "1"
}

extension SGFeedCategory: Equatable, Hashable {
    static func == (lhs: SGFeedCategory, rhs: SGFeedCategory) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    var hashValue: Int {
        return self.rawValue.hashValue
    }
}



enum SGFeedType {
    case myFeeds
    case myFollowings
    case allFeedsList
}

enum FeedListUpdateType {
    case delete(Int)
    case reported(Int)
}

struct FeedNotificationKey {
    static let listUpdateType = "Update Type"
}

protocol LoadableObject: ObservableObject {
    associatedtype Output
    var state: LoadingState<Output> { get }
    func load()
}

enum LoadingState<Value> {
    case idle
    case loading
    case failed(Error)
    case loaded(Value)
}

enum AppUpdateType {
    case celebBlocked(Int)
    case celebUnblocked(Int)
}

struct AppUpdateNotificationKey {
    static let updateType = "Update Type"
}

enum AppRedirectType {
    case feed(Int)
    case event(Int)
    case celebrity(Int)
}
