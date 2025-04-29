//
//  GetCommentResponse.swift
//  stargaze
//
//  Created by Girish Rathod on 28/02/22.
//

import Foundation


public struct GetCommentResponse : Codable{
    public var result : [Comments]
    public var nextPageToken : String?
    
    enum CodingKeys: String, CodingKey{
        case result
        case nextPageToken = "recommId"
    }
    
    public init(result: [Comments], recomm_id: String?){
        self.result = result
        self.nextPageToken = (recomm_id != nil) ? recomm_id : ""
    }
}


struct GetEventCommentResponse : Codable{
    var result : [EventComments]
    var nextPageToken : String?
    
    enum CodingKeys: String, CodingKey{
        case result
        case nextPageToken = "recommId"
    }
    
    init(result: [EventComments], recomm_id: String?){
        self.result = result
        self.nextPageToken = (recomm_id != nil) ? recomm_id : ""
    }
}
