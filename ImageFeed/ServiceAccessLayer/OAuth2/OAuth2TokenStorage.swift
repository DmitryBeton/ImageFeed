//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Дмитрий Чалов on 10.09.2025.
//

import Foundation

final class OAuth2TokenStorage {
    
    private let dataStorage =  UserDefaults.standard
    private let tokenKey = "token"
    
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    var token: String? {
        get {
            print("🔍 Reading token from storage:")
            return dataStorage.string(forKey: tokenKey)
        }
        set {
            print("💾 Saving token to storage:", newValue ?? "nil")
            if let token = newValue {
                dataStorage.set(token, forKey: tokenKey)
            } else {
                dataStorage.removeObject(forKey: tokenKey)
            }
        }
    }
}
