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
            return UserDefaults.standard.string(forKey: "OAuth2Token") ?? "nil"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "OAuth2Token")
        }
    }
}
