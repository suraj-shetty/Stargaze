//
//  SGAPIConstant.swift
//  StarGaze
//
//  Created by Suraj Shetty on 15/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import Foundation

//let baseURL = "http://15.206.212.110:8080/api"
//
//let urlPrefix = "https://"
//
//var baseURL_User = "api-user.stargaze.ai"
//var baseURL_Social = "api-social.stargaze.ai"
//var baseURL_Event = "api-event.stargaze.ai"

//var baseURL_User = "api-user-qa.stargaze.ai"
//var baseURL_Social = "api-social-qa.stargaze.ai"
//var baseURL_Event = "api-event-qa.stargaze.ai"

//let api_Postfix = "/api/v1/"
//
//let userBaseUrlString = urlPrefix+baseURL_User+api_Postfix
//let socialBaseUrlString = urlPrefix+baseURL_Social+api_Postfix
//let eventBaseUrlString = urlPrefix+baseURL_Event+api_Postfix



//for API calls
extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

//For API calls
extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
