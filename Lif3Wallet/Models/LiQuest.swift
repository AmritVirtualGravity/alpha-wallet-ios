//
//  LiQuest.swift
//  Lif3Wallet
//
//  Created by Amrit Duwal on 4/17/23.
//

import Foundation

// MARK: - Welcome
struct LiQuest: Codable {
    let connections: [LiQuestConnection]?
}

// MARK: - Connection
struct LiQuestConnection: Codable {
    let fromChainId, toChainId: Int?
    let fromTokens, toTokens: [LiQuestToken]?
}

// MARK: - Token
struct LiQuestToken: Codable { // same as Token from SwapQuote
    let address: String?
    let chainId: Int?
    let symbol: String?
    let decimals: Int?
    let name, priceUSD, coinKey: String?
    let logoURI: String?
}
