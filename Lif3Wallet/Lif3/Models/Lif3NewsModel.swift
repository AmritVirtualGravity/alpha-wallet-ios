//
//  Lif3NewsModel.swift
//  Lif3Wallet
//
//  Created by Vanila Tech Bibhut on 2/24/23.
//

import Foundation

struct Lif3NewsModel: Codable {
    // MARK: Properties
    var news: [Lif3NewsListModel]?
    
    
    enum CodingKeys: String, CodingKey {
        case news = "Lif3News"
    }
}
