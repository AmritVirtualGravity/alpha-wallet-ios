//
//  TokenParent.swift
//  Pools
//
//  Created by Amrit Duwal on 4/5/23.
//

import Foundation

// MARK: - Welcome
struct TokenParent: Codable {
    let tokens: [PoolToken]?
}

// MARK: - Token
struct PoolToken: Codable {
    let token, staking: String?
}
