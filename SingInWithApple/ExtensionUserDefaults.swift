//
//  ExtensionUserDefaults.swift
//  SingInWithApple
//
//  Created by mac-00014 on 10/12/19.
//  Copyright © 2019 Mind. All rights reserved.
//

import Foundation

private extension String {
    static let userInfo = "user_info"
}

extension UserDefaults {
    
    func fetchUserInfo() -> [String:Any] {
        
        if let userInfo = self.value(forKey: .userInfo) as? [String : Any] {
            return userInfo
        }
        return [:]
    }
    
    func saveUserInfo(_ userInfo : [String: Any]?) {
        
        if let userInfo = userInfo {
            setValue(userInfo, forKey: .userInfo)
            synchronize()
        }
    }
    
    func removeUser() {
        self.removeObject(forKey: .userInfo)
    }
    
    func currentUserIdentifier() -> String? {
        
        let userInfo = self.fetchUserInfo()
        
        if let identifier = userInfo["user_id"] as? String {
            return identifier
        }
        return nil
    }
}
