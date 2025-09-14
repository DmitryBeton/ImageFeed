//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Дмитрий Чалов on 10.09.2025.
//

import Foundation

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    var token: String? {
        get {
            print("🔍 Reading token from storage: \(UserDefaults.standard.string(forKey: "OAuth2Token") ?? "nil")")
            return UserDefaults.standard.string(forKey: "OAuth2Token") ?? nil
        }
        set {
            print("💾 Token saved to storage: \(String(describing: newValue))")
            UserDefaults.standard.set(newValue, forKey: "OAuth2Token")
        }
    }
}
