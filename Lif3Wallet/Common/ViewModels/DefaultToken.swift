//
//  DefaultToken.swift
//  Lif3Wallet
//
//  Created by Vanila Tech Bibhut on 3/1/23.
//

import Foundation
import UIKit
import AlphaWalletFoundation



struct DefaultToken {
    var address: String?
    var server: RPCServer?
    
    init(address: String? = nil, server: RPCServer? = nil) {
        self.address = address
        self.server = server
    }
}
