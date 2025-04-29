//
//  User.swift
//  stargaze
//
//  Created by Girish Rathod on 09/02/22.
//

public enum UserRole: String, Codable {
    case user = "USER"
    case celebrity = "CELEBRITY"
}


public struct User : Codable{
    
    public var id : Int
    public var role : UserRole
    public var token : String
    public var dob : String?
    
    public var name : String?
    public var bio : String?
    public var picture : String?
    public var email : String?
    
    public var mobileNumber : String
    public var countryCode : String

    enum CodingKeys: String, CodingKey{
        case id
        case role
        case token
        case dob
        case name
        case bio
        case picture
        case email
        case mobileNumber
        case countryCode
    }

//    public init(user_id: Int, user_role: String, token: String, dateOfBirth: String, user_name: String, user_bio: String, pictureLink: String, email_id: String, phoneNumber: String, country_code: String){
//        self.id = user_id
//        self.role = user_role
//        self.token = token
//        self.dob = dateOfBirth
//        self.name = user_name
//        self.bio = user_bio
//        self.picture = pictureLink
//        self.email = email_id
//        self.mobileNumber = phoneNumber
//        self.countryCode = country_code
//    }
    
}
    
