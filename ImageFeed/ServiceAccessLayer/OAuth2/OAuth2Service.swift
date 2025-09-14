import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init() { }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            print("❌ Ошибка: неверный URL для запроса токена")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        print("➡️ Формируем POST-запрос для получения токена")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyComponents = [
            "client_id=\(Constants.accessKey)",
            "client_secret=\(Constants.secretKey)",
            "redirect_uri=\(Constants.redirectURI)",
            "code=\(code)",
            "grant_type=authorization_code"
        ]
        let bodyString = bodyComponents.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)
        print("ℹ️ Тело запроса: \(bodyString)")
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                print("📩 Ответ Unsplash: \(String(data: data, encoding: .utf8) ?? "nil")")
                
                do {
                    let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    let accessToken = tokenResponse.access_token
                    OAuth2TokenStorage.shared.token = accessToken
                    print("✅ Токен успешно получен:", accessToken)
                    DispatchQueue.main.async { completion(.success(accessToken)) }
                } catch {
                    print("❌ Ошибка при декодировании токена:", error)
                    completion(.failure(NetworkError.decodingError(error)))
                }
                
            case .failure(let error):
                print("Ошибка сети:", error)
                
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .httpStatusCode(let code):
                        print("❌ HTTP ошибка: статус код", code)
                    case .urlRequestError(let underlyingError):
                        print("❌ Ошибка запроса:", underlyingError)
                    case .urlSessionError:
                        print("❌ Неизвестная ошибка сессии")
                    case .invalidRequest:
                        print("❌ Невалидный запрос")
                    case .decodingError(let decodingError):
                        print("❌ Ошибка декодирования:", decodingError)
                    }
                }
                
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
