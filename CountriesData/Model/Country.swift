//  Country.swift
//  Country
//
//  Created by Aleem on 27/03/2026.
//


import Foundation

struct Country: Decodable, Equatable {
    let name: String
    let region: String
    let code: String
    let capital: String

    enum CodingKeys: String, CodingKey {
        case name
        case region
        case code
        case capital
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = (try? container.decode(String.self, forKey: .name)) ?? ""
        region = (try? container.decode(String.self, forKey: .region)) ?? ""
        code = (try? container.decode(String.self, forKey: .code)) ?? ""
        capital = (try? container.decode(String.self, forKey: .capital)) ?? ""
    }

    init(name: String, region: String, code: String, capital: String) {
        self.name = name
        self.region = region
        self.code = code
        self.capital = capital
    }
}
