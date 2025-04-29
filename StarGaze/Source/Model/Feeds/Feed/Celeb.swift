//
//  Celeb.swift
//  stargaze
//
//  Created by Girish Rathod on 09/02/22.
//

import Foundation

public struct Celeb: Codable{
    var id : Int?
    var name : String?
    var picture : String?
    var isCelebSub: Bool?
    
    enum CodingKeys: String, CodingKey{
        case id
        case name
        case picture
        case isCelebSub
    }
    
    public init(id: Int, name: String, picture: String){
        self.id = id
        self.name = name
        self.picture = picture
        self.isCelebSub = false
    }
}

extension Celeb: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
