//  NetworkService.swift
//  NetworkService
//
//  Created by Aleem on 27/03/2026.
//


import Foundation

protocol NetworkServiceProtocol {
    func fetchCountries(from url: URL, completion: @escaping (Result<[Country], NetworkError>) -> Void)
}

final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchCountries(from url: URL, completion: @escaping (Result<[Country], NetworkError>) -> Void) {
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.unknown(error.localizedDescription)))
                return
            }

            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(.requestFailed(statusCode: httpResponse.statusCode)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            do {
                let countries = try JSONDecoder().decode([Country].self, from: data)
                completion(.success(countries))
            } catch {
                completion(.failure(.decodingFailed))
            }
        }
        task.resume()
    }
}
