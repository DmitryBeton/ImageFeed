//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Дмитрий Чалов on 26.10.2025.
//

import Foundation

protocol AuthHelperProtocol {
    func getCode(from url: URL) -> String?
    var authURLRequest: URLRequest? { get }
}

final class AuthHelper: AuthHelperProtocol {
    private let configuration: AuthConfiguration
    
    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    var authURLRequest: URLRequest? {
       guard let url = authURL() else { return nil }
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
    
    func getCode(from url: URL) -> String? {
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
