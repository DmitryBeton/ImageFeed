import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in  // Создаём замыкание fulfillCompletionOnTheMainThread — его задачей будет выполнять любой код на главном потоке.
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data)) // Возвращаем полученное тело ответа как успешный результат работы запроса.
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode))) // Возвращаем ошибку, связанную с неблагоприятным диапазоном статуса кода ответа (это все варианты, которые попали в 3хх, 4хх и 5хх).
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error))) // Возвращаем ошибку, которую получили в результате работы URLSession.dataTask — сетевую ошибку.
            } else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError)) // Возвращаем ошибку, связанную с остальными случаями. Здесь мы, скорее всего, не получили ни тело ответа, ни ошибку — это непонятное состояние тоже засчитаем как ошибку работы запроса данных.
            }
        })
        
        return task
    }
}
