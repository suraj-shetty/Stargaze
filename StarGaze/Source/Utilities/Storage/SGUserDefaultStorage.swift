//
//  SGUserDefaultStorage.swift
//  StarGaze
//
//  Created by Suraj Shetty on 25/04/22.
//  Copyright © 2022 Day1Tech. All rights reserved.
//

import UIKit

class SGUserDefaultStorage: NSObject {

    class func saveUserData(user: UserDetail){
        let encoder = JSONEncoder()
        do{
            let data = try encoder.encode(user)
            UserDefaults.standard.set(data, forKey: KEY_USER_DATA)
        }catch let encodeError {
            print("Encoder error ", encodeError)
        }
    }
    
    class func getUserData() -> UserDetail? {
        if let data = UserDefaults.standard.data(forKey: KEY_USER_DATA){
            do{
                let decoder = JSONDecoder()
                let user_data = try decoder.decode(UserDetail.self, from: data)
                return user_data
            }catch let parseError {
                print("User data parse error - ", parseError )
            }
        }
        
        return nil
    }
    
    class func saveToken(token: String) {
        UserDefaults.standard.set(token, forKey: KEY_TOKEN)
        UserDefaults.standard.synchronize()
    }
    
    class func getToken() -> String? {
        guard let token = UserDefaults.standard.string(forKey: KEY_TOKEN)
        else {
            return nil
        }

        return token
    }
    
    
    class func clearData(){
        UserDefaults.standard.removeObject(forKey: KEY_USER_DATA)

    }
}
