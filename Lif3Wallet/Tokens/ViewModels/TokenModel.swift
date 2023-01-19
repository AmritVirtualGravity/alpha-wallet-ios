//
//  TokenModel.swift
//  Lif3Wallet
//
//  Created by Vanila Tech Bibhut on 1/9/23.
//

import Foundation

struct TokenModel: Codable {
    let address: String?
    let symbol: String?

    enum CodingKeys: String, CodingKey {
        case address = "address"
        case symbol = "symbol"
    }
}
