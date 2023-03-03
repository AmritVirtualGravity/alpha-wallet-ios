//
//  SelectableSlippageViewModel.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 14.03.2022.
//

import UIKit
import AlphaWalletFoundation

struct SelectableSlippageViewModel {
    let value: SwapSlippage
    var borderWidth: CGFloat = 1
    var borderColor: UIColor = ConfigurationLif3.Color.Semantic.secondaryButtonTextInactive
    var cornerRadius: CGFloat = 4.0
    var isSelected: Bool
    var backgroundColor: UIColor {
        return isSelected ? ConfigurationLif3.Color.Semantic.periodButtonNormalText : ConfigurationLif3.Color.Semantic.periodButtonNormalBackground
    }

    var titleAttributedString: NSAttributedString {
        let textColor: UIColor = isSelected ? ConfigurationLif3.Color.Semantic.defaultInverseText : ConfigurationLif3.Color.Semantic.defaultForegroundText
        return .init(string: value.title, attributes: [
            .font: Fonts.regular(size: 17),
            .foregroundColor: textColor
        ])
    }
}
