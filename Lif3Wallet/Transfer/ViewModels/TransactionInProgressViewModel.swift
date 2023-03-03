//
//  TransactionInProgressViewModel.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 15.07.2020.
//

import UIKit
import AlphaWalletFoundation

struct TransactionInProgressViewModel {
    
    private var server: RPCServer
    
    init(server: RPCServer) {
        self.server = server
    }
    
    var titleAttributedText: NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .center

        return NSAttributedString(string: R.string.localizable.aWalletTokenTransactionInProgressTitle(), attributes: [
            .paragraphStyle: style,
            .font: Fonts.regular(size: 28),
            .foregroundColor: Configuration.Color.Semantic.defaultTitleText
        ])
    }

    var subtitleAttributedText: NSAttributedString {
        let x = R.string.localizable.aWalletTokenTransactionInProgressSubtitle(server.name)
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.lineSpacing = ScreenChecker().isNarrowScreen ? 7 : 14

        return NSMutableAttributedString(string: x, attributes: [
            .paragraphStyle: style,
            .font: Fonts.regular(size: 17),
            .foregroundColor: Configuration.Color.Semantic.defaultHeadlineText
        ])
    }

    var okButtonTitle: String {
        return R.string.localizable.aWalletTokenTransactionInProgressConfirm()
    }

    var image: UIImage? {
        return R.image.conversionDaiSai()
    }

    var backgroundColor: UIColor {
        return Configuration.Color.Semantic.defaultViewBackground
    }
}

