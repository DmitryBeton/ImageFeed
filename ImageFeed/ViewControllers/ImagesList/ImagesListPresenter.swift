//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Дмитрий Чалов on 27.10.2025.
//
import UIKit

protocol ImagesListViewProtocol: AnyObject {
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
    func reloadRow(at indexPath: IndexPath)
    func showError(_ message: String)
}

final class ImagesListPresenter {
    weak var view: ImagesListViewProtocol?
    private let imagesListService = ImagesListService.shared
    private(set) var photos: [Photo] = []
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .none
        return f
    }()
    
    // MARK: - Init
    init(view: ImagesListViewProtocol?) {
        self.view = view
        setupObservers()
    }
    
    // MARK: - Public Methods
    func fetchNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func photo(at indexPath: IndexPath) -> Photo {
        photos[indexPath.row]
    }
    
    func numberOfPhotos() -> Int {
        photos.count
    }
    
    func dateText(for photo: Photo) -> String {
        if let date = photo.createdAt {
            return dateFormatter.string(from: date)
        } else {
            return ""
        }
    }
    
    func likePhoto(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                completion(self.photos[indexPath.row].isLiked)
            case .failure(let error):
                self.view?.showError("Не удалось изменить лайк: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Private
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            let oldCount = self.photos.count
            let newCount = self.imagesListService.photos.count
            self.photos = self.imagesListService.photos
            self.view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
        }
    }
}
