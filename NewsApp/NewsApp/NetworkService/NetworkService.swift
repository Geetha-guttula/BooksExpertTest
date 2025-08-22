//
//  NetworkService.swift
//
//  Created by Geetha Sai Durga on 20/07/25.
//

import Foundation

/// Enum representing common networking errors
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case unknown(Error)
}

class NetworkService {
    static let shared = NetworkService()
    private init() {}

    private let baseURL = AppConstants.baseUrl
    /// Fetches Swift repositories from GitHub
    func fetchSwiftRepositories(completion: @escaping (Result<[Article], NetworkError>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            // Handle error case
            if let error = error {
                completion(.failure(.unknown(error)))
                return
            }
            // Handle empty data
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            // Decoding into model
            do {
                let decoded = try JSONDecoder().decode(NewsListModel.self, from: data)
                let repos = decoded.articles ?? []
                print("data" , repos )
                completion(.success(repos))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
}
