//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Чалов on 19.08.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let imageView: UIImageView = {
        let profileImage = UIImage(named: "profileIcon")
        let imageView = UIImageView(image: profileImage)
        imageView.image = profileImage
        imageView.tintColor = .gray
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = .systemFont(ofSize: 23, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.textColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, World!"
        label.textColor = .white
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(resource: .logoutButton), for: .normal)
        button.tintColor = UIColor(red: 245/255, green: 107/255, blue: 108/255, alpha: 1)
        button.addTarget(self,
                         action: #selector(logoutButtonTapped),
                         for: .touchUpInside)
        return button
    }()
    
    // MARK: - Vars
    private let tokenStorage = OAuth2TokenStorage.shared
    
    private var profileImageServiceObserver: NSObjectProtocol?

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstrains()
        if let profile = ProfileService.shared.profile {
            print("🐳 Update profile details...")
            updateProfileDetails(with: profile)
        }
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    // MARK: - Private Methods
    private func updateProfileDetails(with profile: Profile) {
        nameLabel.text = profile.name.isEmpty ? "Имя не указано" : profile.name
        usernameLabel.text = profile.name.isEmpty ? "@неизвестный_пользователь" : "@\(profile.username)"
        descriptionLabel.text = profile.name.isEmpty ? "Профиль не заполнен" : profile.bio
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
            // TODO: Add Avatar
        else { return }
    }
    
    // MARK: - Setup UI
    
    func setupUI() {
        view.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1)
        view.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(usernameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
    }
    
    // MARK: - Layout
    
    func setupConstrains() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8).isActive = true
        
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        logoutButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
    }
    
    // MARK: - Actions
    
    @objc private func logoutButtonTapped(_ sender: UIButton) {
    }
}
