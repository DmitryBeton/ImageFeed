//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Чалов on 19.08.2025.
//

import UIKit
import Kingfisher

protocol ProfileViewProtocol: AnyObject {
    func updateProfileDetails(with profile: Profile)
    func updateAvatar(with url: URL?)
    func showLogoutAlert()
}

final class ProfileViewController: UIViewController, ProfileViewProtocol {
    private var presenter: ProfilePresenter!

    // MARK: - UI Elements
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person.circle.fill"))
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Full name"
        label.font = .systemFont(ofSize: 23, weight: .bold)
        label.textColor = .white
        label.accessibilityIdentifier = "Name Lastname"
        return label
    }()

    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "@nickname"
        label.textColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
        label.font = .systemFont(ofSize: 13)
        label.accessibilityIdentifier = "@username"

        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, World!"
        label.textColor = .white
        label.font = .systemFont(ofSize: 13)
        return label
    }()

    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(resource: .logoutButton), for: .normal)
        button.tintColor = UIColor(red: 245/255, green: 107/255, blue: 108/255, alpha: 1)
        button.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        button.accessibilityIdentifier = "@logout button"
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()

        presenter = ProfilePresenter(view: self)
        presenter.viewDidLoad()
    }

    // MARK: - Actions
    @objc private func logoutTapped() {
        presenter.didTapLogout()
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1)
        [imageView, nameLabel, usernameLabel, descriptionLabel, logoutButton].forEach { view.addSubview($0) }
    }

    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),

            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),

            usernameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),

            descriptionLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),

            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }

    // MARK: - ProfileViewProtocol
    func updateProfileDetails(with profile: Profile) {
        print("🔹 Updating profile UI for \(profile.username)")
        nameLabel.text = profile.name.isEmpty ? "Имя не указано" : profile.name
        usernameLabel.text = "@\(profile.username)"
        descriptionLabel.text = ((profile.bio?.isEmpty) != nil) ? "Профиль не заполнен" : profile.bio
    }

    func updateAvatar(with url: URL?) {
        let placeholder = UIImage(resource: .stub)
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: url, placeholder: placeholder, options: [.processor(processor)])
    }

    func showLogoutAlert() {
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены, что хотите выйти?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Да", style: .destructive) { _ in
            ProfileLogoutService.shared.logout()
        })
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))

        present(alert, animated: true)
    }
}
