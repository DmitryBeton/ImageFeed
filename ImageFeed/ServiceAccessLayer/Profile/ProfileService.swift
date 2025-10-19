//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Дмитрий Чалов on 22.09.2025.
//

import Foundation

final class ProfileService {
    // MARK: - Singleton
    static let shared = ProfileService()
    private init() {}
    
    // MARK: - Properties
    private(set) var profile: Profile?

    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    
    // MARK: - Public methods
    func cleanProfileService() {
        profile = nil
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()

        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let result):
                let profile = Profile(
                    username: result.username,
                    name: "\(result.firstName) \(result.lastName)"
                        .trimmingCharacters(in: .whitespaces), // Убираем лишние пробелы
                    loginName: "@\(result.username)",
                    bio: result.bio
                )

                self?.profile = profile
                print("👌 Profile Data Fetched")
                completion(.success(profile))
            case .failure(let error):
                print("[fetchProfile]: Ошибка запроса: \(error.localizedDescription)")
                completion(.failure(error))
            }
            self?.task = nil
        }
        
        self.task = task
        task.resume()
    }

    // MARK: - Private methods
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
