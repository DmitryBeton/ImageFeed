//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Дмитрий Чалов on 26.10.2025.
//

import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {
    let configuration: AuthConfiguration
    
    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    
    func authRequest() -> URLRequest? {
        print("🌐 Loading Unsplash auth page…")
        guard let url = authURL() else { return nil }
        print("🔗 Final Auth URL:", url.absoluteString)
        return URLRequest(url: url)
    }
    
    func authURL() -> URL? {
        
        guard var urlComponents = URLComponents(string: configuration.authURLString) else {
            print("❌ Failed to create URL")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]
        
        return urlComponents.url
    }
    
    func code(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
