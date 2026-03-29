//  NetworkError.swift
//  NetworkError
//
//  Created by Aleem on 27/03/2026.
//


import Foundation

enum NetworkError: Error, Equatable {
    case invalidURL
    case noData
    case decodingFailed
    case requestFailed(statusCode: Int)
    case unknown(String)

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "The URL provided is not valid."
        case .noData:
            return "No data was returned from the server."
        case .decodingFailed:
            return "Failed to parse the server response."
        case .requestFailed(let code):
            return "Request failed with status code \(code)."
        case .unknown(let message):
            return message
        }
    }
}
