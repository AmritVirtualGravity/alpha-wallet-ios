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
        static let server = "AlphaWallet"
        static let websiteUrl = URL(string: Constants.website)!
        static let icons = [
            "https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media"
        ]
        static let connectionTimeout: TimeInterval = 10
    }

    static let launchShortcutKey = "com.stormbird.alphawallet.qrScanner"

    // social
    static let website = "https://lif3.com/"
    static let twitterUsername = "AlphaWallet"
    static let redditGroupName = "r/AlphaWallet/"
    static let facebookUsername = "AlphaWallet"

    // support
    static let supportEmail = "feedback+ios@alphawallet.com"

    static let dappsBrowserURL = URL(string: "http://aw.app")!
    
    //Swap URL
    static let swapWebsiteUrl  = "https://lif3.com/swap"
    //Life URL
    static let lifeWebUrl  = "https://lif3.com"
    static let lifeSwapTokenWebUrl  = "https://lif3.com/app-swap"
    static let lifeGardenWebUrl  = "https://lif3.com/garden"
    static let lifeFountainWebUrl  = "https://lif3.com/fountain"
    static let lifeTerraceWebUrl  = "https://lif3.com/terrace"
    static let lifeGreenhouseWebUrl  = "https://lif3.com/greenhouse"
    static let lifeNurseryWebUrl  = "https://lif3.com/nursery"
    
    
    static let  defaultTokens = [DefaultToken(address: "0xbf60e7414EF09026733c1E7de72E7393888C64DA", server: .fantom),DefaultToken(address: "0xCbE0CA46399Af916784cADF5bCC3aED2052D6C45", server: .fantom),DefaultToken(address: "0x5f0456f728e2d59028b4f5b8ad8c604100724c6a", server: .fantom),DefaultToken(address: "0x4200000000000000000000000000000000000108", server: .tomb_chain),DefaultToken(address: "0x4200000000000000000000000000000000000109", server: .tomb_chain),DefaultToken(address: "0x94bb580d7f99c30f125669bfaf8164d5ff6436e7", server: .tomb_chain),DefaultToken(address: "0x80D2Fe89b6C6c24edfB553DAF35599649AC55283", server: .binance_smart_chain),DefaultToken(address: "0xF70B6D6AcD652612f24F7DD2CA2F1727eB20793a", server: .binance_smart_chain),DefaultToken(address: "0xDEa12C8C23994EA2D88eD99eE1bdc0FF56f7F9d1", server: .binance_smart_chain),DefaultToken(address: "0x56ac3Cb5E74b8A5A25ec9Dc05155aF1dad2715bd", server: .polygon),DefaultToken(address: "0xFB40b1eFe90D4b786D2D9d9dc799B18BDe92923b", server: .polygon),DefaultToken(address: "0x2C2D8a078B33bf7782a16AcCE2C5BA6653a90D5f", server: .polygon)]
}
