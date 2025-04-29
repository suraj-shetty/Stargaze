//
//  Feeds.swift
//  stargaze
//
//  Created by Girish Rathod on 09/02/22.
//

import Foundation

public struct Feeds : Codable{
    public var result : Posts
    
    enum CodingKeys: String, CodingKey{
        case result
    }
    
    public init(result: Posts){
        self.result = result
    }
}

public struct FilterCategory : Codable{
    var id : Int
    var name : String!
    var status : String
    var createdAt : String
    var updatedAt : String
    var parentCategoryId : Int?
    var subCategory : [FilterCategory]?
    
    enum CodingKeys: String, CodingKey{
        case id
        case name
        case status
        case createdAt
        case updatedAt
        case parentCategoryId
        case subCategory
    }
    
    public init(cat_id:Int, cat_name: String, cat_status:String, cat_created:String, cat_updated: String, cat_parent_id: Int?, sub_cat: [FilterCategory]){
        self.id = cat_id
        self.name = cat_name
        self.status = cat_status
        self.createdAt = cat_created
        self.updatedAt = cat_updated
        self.parentCategoryId = cat_parent_id ?? 0
        self.subCategory = sub_cat
    }
}

    
public struct CategoryResponse : Codable{
    public var result : [FilterCategory]
    
    enum CodingKeys: String, CodingKey{
        case result
    }
    
    public init(response: [FilterCategory]){
        self.result = response
    }
}
