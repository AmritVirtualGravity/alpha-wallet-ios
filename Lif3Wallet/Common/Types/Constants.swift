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
}
