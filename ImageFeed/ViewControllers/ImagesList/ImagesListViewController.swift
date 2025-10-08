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
    //    private let photoNames = (0..<20).map(String.init)
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private let imageListService = ImagesListService.shared
    private var photos: [Photo] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupObservers()
        
        // Загружаем первую страницу
        if imageListService.photos.isEmpty {
            print("Нет фото, Загружаем новые...")
            imageListService.fetchPhotosNextPage()
        } else {
            print("Есть фото, Достаю из памяти")
            photos = imageListService.photos
        }
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = .ypBlack
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
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
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateTableViewAnimated()
        }
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        photos = imageListService.photos
        let newCount = photos.count
        
        print("🔄 Обновление таблицы: было \(oldCount), стало \(newCount)")
        
        // Если это первая загрузка или добавлено много элементов - используем reloadData
        if oldCount == 0 || newCount - oldCount > 5 {
            tableView.reloadData()
        } else {
            // Для небольших добавлений используем анимированное обновление
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map {
                    IndexPath(row: $0, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) // 1
        guard let imageListCell = cell as? ImagesListCell else { // 2
            return UITableViewCell()
        }
        // Защитная проверка индекса
        guard indexPath.row < photos.count else {
            print("❌ Ошибка: индекс \(indexPath.row) выходит за границы массива photos (количество элементов: \(photos.count))")
            // Можно вернуть пустую ячейку или ячейку с сообщением об ошибке
            return imageListCell
        }
        let photo = photos[indexPath.row]
        configCell(for: imageListCell, with: photo, at: indexPath) // 3
        return imageListCell // 4
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    //    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
    //        guard let image = UIImage(named: photoNames[indexPath.row]) else {
    //            return
    //        }
    //        cell.setCellImage(image)
    //        cell.setLabelDate(dateFormatter.string(from: Date()))
    //        
    //        let isLiked = indexPath.row % 2 == 0
    //        let likeImage = isLiked ? UIImage(resource: .likeButtonOn) : UIImage(resource: .likeButtonOff)
    //        cell.setLikeButtonImage(likeImage)
    //    }
    
    func configCell(for cell: ImagesListCell, with photo: Photo, at indexPath: IndexPath) {
        // Устанавливаем дату
        if let createdAt = photo.createdAt {
            cell.setLabelDate(dateFormatter.string(from: createdAt))
        } else {
            cell.setLabelDate("")
        }
        
        // Загружаем изображение с помощью Kingfisher
        if let url = URL(string: photo.largeImageURL) {
            cell.setCellImage(with: url)
        }
        
        // Устанавливаем лайк
        let likeImage = photo.isLiked ? UIImage(resource: .likeButtonOn) : UIImage(resource: .likeButtonOff)
        cell.setLikeButtonImage(likeImage)
        
        // Обработка лайка
        //        cell.onLikeButtonTapped = { [weak self] in
        //            self?.handleLikeTapped(for: photo, at: indexPath)
        //        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //        guard let image = UIImage(named: photoNames[indexPath.row]) else {
        //            return 0
        //        }
        
        guard indexPath.row < photos.count else {
            return 200 // Возвращаем стандартную высоту при ошибке
        }
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("✅ cell select: \(indexPath.row)")
        guard indexPath.row < photos.count else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        let photo = photos[indexPath.row]
        
        let singleImageVC = SingleImageViewController()
        if let url = URL(string: photo.largeImageURL) {
            singleImageVC.imageURL = url
        }
        singleImageVC.modalPresentationStyle = .fullScreen
        
        present(singleImageVC, animated: true)
        
        // Снимаем выделение
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 2 {
            imageListService.fetchPhotosNextPage()
        }
        
    }
}
