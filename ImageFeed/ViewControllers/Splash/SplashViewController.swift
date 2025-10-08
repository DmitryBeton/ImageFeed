//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Чалов on 10.09.2025.
//

import UIKit

final class SplashViewController: UIViewController {
// MARK: - UI Elements
    private let imageView: UIImageView = {
        let image = UIImage(named: "Splash_screen_logo")
        let imageView = UIImageView(image: image)
        return imageView
    }()

// MARK: - Vars
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let storage = OAuth2TokenStorage.shared
    private var didCheckAuth = false
    private let profileService = ProfileService.shared
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstrains()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Защита от повторного выполнения
        guard !didCheckAuth else { return }
        didCheckAuth = true
        
        print("🚀 SplashViewController appeared")
        print("📋 Token check:", storage.token != nil ? "EXISTS" : "MISSING")
        if let token = storage.token {
            print("➡️ Switching to TabBar")
            fetchProfile(token: token)
        } else {
            print("➡️ Showing auth screen")
            presentAuthViewController()
//            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
// MARK: - Private Methods
    private func switchToTabBarController() {
        print("🎯 Switching to TabBarController")
        guard let window = UIApplication.shared.windows.first else {
            print("❌ No window found!")
            assertionFailure("Invalid window configuration")
            return
        }
        
        // BEFORE:
//        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
//            .instantiateViewController(withIdentifier: "TabBarViewController")
//        print("✅ TabBarController created successfully")
//        window.rootViewController = tabBarController
        // AFTER:
        let tabBarController = TabBarViewController()
        print("✅ TabBarController created successfully")
        window.rootViewController = tabBarController

    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case let .success(profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToTabBarController()
            case let .failure(error):
                print(error)
                break
            }
        }
    }
    
    private func presentAuthViewController() {
        let authViewController = AuthViewController()
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось загрузить профиль",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1)
        view.addSubview(imageView)
    }
    // MARK: - Layout
    private func setupConstrains() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

// MARK: - Exstensions
//extension SplashViewController {
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == showAuthenticationScreenSegueIdentifier {
//            guard
//                let navigationController = segue.destination as? UINavigationController,
//                let viewController = navigationController.viewControllers[0] as? AuthViewController
//            else {
//                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
//                return
//            }
//            viewController.delegate = self
//        } else {
//            super.prepare(for: segue, sender: sender)
//        }
//    }
//}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        print("🎯 didAuthenticate called")
        vc.dismiss(animated: true)
        guard let token = storage.token else {
            return
        }
        fetchProfile(token: token)
    }
}
