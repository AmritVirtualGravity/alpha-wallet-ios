//
//  URL.swift
//  Lif3Wallet
//
//  Created by ebpearls on 02/05/2023.
//

import Foundation

extension URL {
    
    static func getImageUrlFromChainId(_ id: Int) -> URL {
        return URL(string: "https://assets.lif3.com/wallet/chains/\(id)-I.svg")!
    }
    
    static func getImageUrlFromChainIdAlternative(_ id: Int) -> URL {
        return URL(string: "https://assets.lif3.com/wallet/chains/\(id).svg")!
    }
    
}
