//
//  RoundedEnsViewModel.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 01.11.2022.
//

import UIKit

struct RoundedEnsViewModel {
    let text: String?
    var isHidden: Bool {
        guard let text = text else { return true }
        return text.isEmpty
    }

    var labelFont: UIFont = Fonts.semibold(size: ScreenChecker.size(big: 17, medium: 16, small: 14))
//    var labelTextColor: UIColor = Configuration.Color.Semantic.labelTextActive
    var labelTextColor: UIColor = .white
//    var backgroundColor: UIColor = Configuration.Color.Semantic.roundButtonBackground
    var backgroundColor: UIColor = .white.withAlphaComponent(0.2)
}
