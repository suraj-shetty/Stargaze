//
//  CoinCreditRequest.swift
//  StarGaze
//
//  Created by Suraj Shetty on 15/09/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

enum CoinCreditStatus: String, Codable {
    case paid = "paid"
    case failed = "failed"
}

struct CoinCreditRequest: Encodable {
    let id: Int
    let receipt: String
    let status: CoinCreditStatus
    let metadata: [String: Any]?
    let desc: String
    
    enum CodingKeys: String, CodingKey {
        case id = "transactionId"
        case receipt = "receipt_id"
        case status = "status"
        case metadata = "data"
        case desc = "description"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(receipt, forKey: .receipt)
        try container.encode(status, forKey: .status)
        try container.encode(desc, forKey: .desc)
        
        if let metadata = metadata, !metadata.isEmpty {
            let data = try JSONSerialization.data(withJSONObject: metadata, options:[])
            try container.encode(data, forKey: .metadata)
        }
        else {
            try container.encodeNil(forKey: .metadata)
        }
    }    
}
