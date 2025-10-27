//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Дмитрий Чалов on 27.10.2025.
//

import UIKit

import Foundation
final class ProfilePresenter {
    private weak var view: ProfileViewProtocol?
    private let profileService = ProfileService.shared
    private let imageService = ProfileImageService.shared
    private var profileImageObserver: NSObjectProtocol?

    init(view: ProfileViewProtocol) {
        self.view = view
    }

    func viewDidLoad() {
        print("🧩 ProfilePresenter.viewDidLoad()")

        // Если профиль уже есть — сразу обновляем
        if let profile = profileService.profile {
            view?.updateProfileDetails(with: profile)
        } else if let token = OAuth2TokenStorage.shared.token {
            // Если профиля нет — подгружаем
            fetchProfile(token: token)
        }

        // Подписываемся на обновление аватара
        profileImageObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }

        updateAvatar()
    }

    func didTapLogout() {
        view?.showLogoutAlert()
    }

    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    print("✅ Profile fetched: \(profile.username)")
                    self.view?.updateProfileDetails(with: profile)
                    self.imageService.fetchProfileImageURL(username: profile.username) { _ in }
                case .failure(let error):
                    print("❌ Failed to fetch profile: \(error)")
                }
            }
        }
    }

    private func updateAvatar() {
        guard let urlString = imageService.avatarURL, let url = URL(string: urlString) else {
            view?.updateAvatar(with: nil)
            return
        }
        view?.updateAvatar(with: url)
    }

    deinit {
        if let observer = profileImageObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
