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
        
        guard let token = OAuth2TokenStorage.shared.token,
              let request = makePhotoImageRequest(page: nextPage, token: token) else {
            isFetching = false
            return
        }
        print("🔄 Загружаем страницу: \(nextPage)")
        
        task?.cancel()
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            print("😭 Загружаем фото...")
            
            defer {
                self.isFetching = false
                self.task = nil
            }
            
            switch result {
            case .success(let result):
                let dateFormatter = ISO8601DateFormatter()
                let newPhotos = result.map { result in
                    Photo(id: result.id,
                          size: CGSize(width: result.width, height: result.height),
                          createdAt: result.createdAt.flatMap { dateFormatter.date(from: $0) },
                          welcomeDescription: result.altDescription ?? "Нет описания",
                          thumbImageURL: result.urls.thumb,
                          largeImageURL: result.urls.full,
                          isLiked: result.likedByUser)
                }
                
                DispatchQueue.main.async {
                    self.lastLoadedPage = nextPage
                    self.photos.append(contentsOf: newPhotos)
                    print("✅ Загружено \(newPhotos.count) фотографий. Всего: \(self.photos.count)")
                    
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
        print("REQUEST CREATED!!!")
        return request
    }
}

