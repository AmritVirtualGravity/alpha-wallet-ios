//
//  Pool.swift
//  Pools
//
//  Created by Amrit Duwal on 3/28/23.
//

import Foundation

// MARK: - Welcome
struct CompanyList: Codable {
    let lif3StakingList, crypoBannerSuggestedStakingList, techSuggestedStakingList: [Company]?
    
    enum CodingKeys: String, CodingKey {
        case lif3StakingList                 = "lif3_staking_list"
        case crypoBannerSuggestedStakingList = "crypo_banner_suggested_staking_list"
        case techSuggestedStakingList        = "tech_suggested_staking_list"
    }
}

// MARK: - StakingList
struct Company: Codable, Hashable {
    let name, icon, tvl, apr: String?
    let token: String?
}
