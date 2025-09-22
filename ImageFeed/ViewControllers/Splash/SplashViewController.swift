//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Чалов on 10.09.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let storage = OAuth2TokenStorage.shared
    private var didCheckAuth = false  // Добавляем флаг

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Защита от повторного выполнения
        guard !didCheckAuth else { return }
        didCheckAuth = true

        print("🚀 SplashViewController appeared")
        print("📋 Token check:", storage.token != nil ? "EXISTS" : "MISSING")

        if storage.token != nil {
            print("➡️ Switching to TabBar")
            switchToTabBarController()
        } else {
            print("➡️ Showing auth screen")
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func switchToTabBarController() {
        print("🎯 Switching to TabBarController")
        guard let window = UIApplication.shared.windows.first else {
            print("❌ No window found!")
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        print("✅ TabBarController created successfully")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        print("🎯 didAuthenticate called")
        vc.dismiss(animated: true)
        switchToTabBarController()
    }
}
