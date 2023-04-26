//
//  Constants.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 14.09.2022.
//

import Foundation
import AlphaWalletFoundation

extension Constants {
    //Misc
    static let etherReceivedNotificationIdentifier = "etherReceivedNotificationIdentifier"

    static let keychainKeyPrefix = "alphawallet"
    static let xdaiDropPrefix = Data([0x58, 0x44, 0x41, 0x49, 0x44, 0x52, 0x4F, 0x50]).hex()

    enum WalletConnect {
        static let server = "Lif3Wallet"
        static let websiteUrl = URL(string: Constants.website)!
        static let icons = [
            "https://assets.lif3.com/swap/tokens/LIF3.svg"
        ]
        static let connectionTimeout: TimeInterval = 10
    }

    static let launchShortcutKey = "com.stormbird.alphawallet.qrScanner"

    // social
    static let website = "https://lif3.com/"
    static let twitterUsername = "Official_LIF3"
    static let redditGroupName = "r/AlphaWallet/"
    static let facebookUsername = "AlphaWallet"

    // support
    static let supportEmail = "ios-feedback@lif3.com"

    static let dappsBrowserURL = URL(string: "http://aw.app")!
    
    static let deBankURL = "https:debank.com/profile/"
    
    //Swap URL
    static let swapWebsiteUrl  = "https://lif3.com/swap"
    //Life URL
    static let lifeWebUrl  = "https://lif3.com"
    static let lifeSwapTokenWebUrl  = "https://lif3.com/swap"
    static let lifeGardenWebUrl  = "https://lif3.com/garden"
    static let lifeFountainWebUrl  = "https://lif3.com/fountain"
    static let lifeTerraceWebUrl  = "https://lif3.com/terrace"
    static let lifeGreenhouseWebUrl  = "https://lif3.com/staking"
    static let lifeNurseryWebUrl  = "https://trade.lif3.com/earn"
    static let lif3TradeUrl  = "https://trade.lif3.com"
    
    
    static let  defaultTokens = [
        DefaultToken(address: "0xbf60e7414EF09026733c1E7de72E7393888C64DA", server:.fantom),
        DefaultToken(address: "0xCbE0CA46399Af916784cADF5bCC3aED2052D6C45", server: .fantom),
        DefaultToken(address: "0x4200000000000000000000000000000000000108", server: .tomb_chain),
        DefaultToken(address: "0x4200000000000000000000000000000000000109", server: .tomb_chain),
        DefaultToken(address: "0x80D2Fe89b6C6c24edfB553DAF35599649AC55283", server: .binance_smart_chain),
        DefaultToken(address: "0xF70B6D6AcD652612f24F7DD2CA2F1727eB20793a", server: .binance_smart_chain),
        DefaultToken(address: "0x56ac3cb5e74b8a5a25ec9dc05155af1dad2715bd", server: .polygon),
        DefaultToken(address: "0xFB40b1eFe90D4b786D2D9d9dc799B18BDe92923b", server: .polygon)
    ]
    
    static func updateSwapTokenName(swapTool: String) -> String {
        
        switch (swapTool) {
        case "spookyswap-ftm":
            return "Spooky Swap"
        case "spiritswap-ftm":
            return "Spirit Swap"
        case "tombswap-ftm":
            return "Tomb Swap"
        case "sushiswap-ftm":
            return "Sushi Swap"
        case "soulswap-ftm":
            return "Soul Swap"
        case "uniswap-eth":
            return "Uniswap"
        case "sushiswap-eth":
            return "Sushi Swap"
        default:
            return swapTool.capitalizingFirstLetter() 
        }
        
    }
}


extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
