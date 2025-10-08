//
//  ViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Чалов on 13.08.2025.
//

import UIKit

final class ImagesListViewController: UIViewController {
    // MARK: - UI Elements
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .ypBlack
        return tableView
    }()
    
    // MARK: - Properties
    private let photoNames = (0..<20).map(String.init)
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .ypBlack
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photoNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) // 1
        guard let imageListCell = cell as? ImagesListCell else { // 2
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath) // 3
        return imageListCell // 4
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: photoNames[indexPath.row]) else {
            return
        }
        cell.setCellImage(image)
        cell.setLabelDate(dateFormatter.string(from: Date()))
        
        let isLiked = indexPath.row % 2 == 0
        let likeImage = isLiked ? UIImage(resource: .likeButtonOn) : UIImage(resource: .likeButtonOff)
        cell.setLikeButtonImage(likeImage)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photoNames[indexPath.row]) else {
            return 0
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("✅ cell select: \(indexPath.row)")
        
        let singleImageVC = SingleImageViewController()
        singleImageVC.image = UIImage(named: photoNames[indexPath.row])
        singleImageVC.modalPresentationStyle = .fullScreen
        
        present(singleImageVC, animated: true)
        
        // Снимаем выделение
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
