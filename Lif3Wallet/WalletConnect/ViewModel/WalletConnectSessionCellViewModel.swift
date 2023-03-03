// Copyright © 2020 Stormbird PTE. LTD.

import UIKit
import AlphaWalletFoundation

struct WalletConnectSessionCellViewModel {
    let session: AlphaWallet.WalletConnect.Session
    var servers: [RPCServer] { session.servers }

    let backgroundColor: UIColor = ConfigurationLif3.Color.Semantic.tableViewBackground

    var serverIconImages: [Subscribable<Image>] {
        servers.map { $0.walletConnectIconImage }
    }

    var sessionNameAttributedString: NSAttributedString {
        let servers = servers.map { $0.name }.joined(separator: ", ")
        return .init(string: "\(session.dappName) (\(servers))", attributes: [
            .font: Fonts.regular(size: 20),
            .foregroundColor: ConfigurationLif3.Color.Semantic.defaultForegroundText
        ])
    }

    var sessionURLAttributedString: NSAttributedString {
        return .init(string: session.dappUrl.absoluteString, attributes: [
            .font: Fonts.regular(size: 12),
            .foregroundColor: ConfigurationLif3.Color.Semantic.defaultSubtitleText
        ])
    }

    var sessionIconURL: URL? {
        return session.dappIconUrl
    }
    
}
