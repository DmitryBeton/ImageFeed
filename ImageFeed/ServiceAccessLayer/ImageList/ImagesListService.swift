//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Дмитрий Чалов on 08.10.2025.
//

import UIKit

final class ImagesListService {
    
    // MARK: - Singleton
    static let shared = ImagesListService()
    private init() {}
    
    // MARK: - Properties
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var isFetching = false
    
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    
    // MARK: - Notification
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // MARK: - Public methods
    func fetchPhotosNextPage() {
        guard !isFetching else { return }
        isFetching = true
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("🔒 Нет токена")
            isFetching = false
            return
        }
        
        guard let request = makePhotoImageRequest(page: nextPage, token: token) else {
            print("⚠️ Не удалось создать запрос")
            isFetching = false
            return
        }

        print("🔄 Загружаем страницу: \(nextPage)")

        task?.cancel()
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            
            defer {
                isFetching = false
            }
            
            switch result {
            case .success(let result):
                let newPhotos = self.mapPhotoResults(result)
                DispatchQueue.main.async {
//                    self.lastLoadedPage = nextPage
//                    self.photos.append(contentsOf: newPhotos)
                    let uniqueNewPhotos = newPhotos.filter { newPhoto in
                        !self.photos.contains(where: { $0.id == newPhoto.id })
                    }

                    guard !uniqueNewPhotos.isEmpty else {
                        print("⚠️ Новых фото нет — возможно, API вернул дубликаты")
                        return
                    }

                    self.lastLoadedPage = nextPage
                    self.photos.append(contentsOf: uniqueNewPhotos)
                    print("✅ Добавлено \(uniqueNewPhotos.count) уникальных фото. Всего: \(self.photos.count)")

                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
            case .failure(let error):
                if (error as NSError).code != NSURLErrorCancelled {
                    print("❌ Ошибка загрузки: \(error.localizedDescription)")
                }
            }
        }
        task?.resume()
    }
    
    // MARK: - Private methods
    private func makePhotoImageRequest(page: Int, perPage: Int = 10, token: String) -> URLRequest? {
        var urlComponents = URLComponents(string: "https://api.unsplash.com/photos")
        
        urlComponents?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        
        guard let url = urlComponents?.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func mapPhotoResults(_ results: [PhotoResult]) -> [Photo] {
        let formatter = ISO8601DateFormatter()
        return results.map { result in
            Photo(
                id: result.id,
                size: CGSize(width: result.width, height: result.height),
                createdAt: result.createdAt.flatMap { formatter.date(from: $0) },
                welcomeDescription: result.altDescription ?? "Нет описания",
                thumbImageURL: result.urls.thumb,
                largeImageURL: result.urls.full,
                regularImageURL: result.urls.regular,
                isLiked: result.likedByUser
            )
        }
    }
}

