//
//  BlackListedToken.swift
//  Lif3Wallet
//
//  Created by Vanila Tech Bibhut on 1/9/23.
//

import Foundation


struct BlackListedTokenModel: Codable {
    let blackListToken: [String]?

    enum CodingKeys: String, CodingKey {
        case blackListToken = "blacklisted"
    }
}
