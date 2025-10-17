//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Дмитрий Чалов on 14.10.2025.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    // MARK: - Singleton
    static let shared = ProfileLogoutService()
    private init() { }
    
    // MARK: - Public methods
    func logout() {
        cleanCookies()
        
        ImagesListService.shared.cleanImagesListService()
        ProfileImageService.shared.cleanProfileImageService()
        ProfileService.shared.cleanProfileService()
        
        OAuth2TokenStorage.shared.token = nil
        
        print("🚪 Leave from profile")
        switchToSplashViewController()
    }
    
    // MARK: - Private methods
    private func cleanCookies() {
        // Очищаем все куки из хранилища
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            // Массив полученных записей удаляем из хранилища
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func switchToSplashViewController() {
        print("🎯 Switching to SplashViewController")
        guard let window = UIApplication.shared.windows.first else {
            print("❌ No window found!")
            assertionFailure("Invalid window configuration")
            return
        }
        let splashViewController = SplashViewController()
        print("✅ SplashViewController created successfully")
        window.rootViewController = splashViewController
    }
}
