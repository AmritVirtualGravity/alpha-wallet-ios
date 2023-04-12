//
//  Pool.swift
//  Pools
//
//  Created by Amrit Duwal on 4/5/23.
//

import Foundation

// MARK: - Pool
struct PoolParent: Codable {
    let pools: [Pool]?
}

// MARK: - Pool
struct Pool: Codable, Hashable {
    let stakingList: String?
    let imageURL: String?
    let list: [PoolCompany]?

    enum CodingKeys: String, CodingKey {
        case stakingList = "staking-list"
        case imageURL = "image-url"
        case list
    }
}

// MARK: - List
struct PoolCompany: Codable, Hashable {
    let token, title, subtitle, aboutProtocol: String?
    let aboutStake: String?
    let urlProtocol, urlStake: String?
    let icon: String?
    let bannerImage: String?
    let poolType, score, isNative: String?
    let urlStaking: String?
    let image: String?

    enum CodingKeys: String, CodingKey {
        case token, title, subtitle
        case aboutProtocol = "about-protocol"
        case aboutStake = "about-stake"
        case urlProtocol = "url-protocol"
        case urlStake = "url-stake"
        case icon
        case bannerImage = "banner-image"
        case poolType = "pool-type"
        case score, isNative
        case urlStaking = "url-staking"
        case image
    }
}
