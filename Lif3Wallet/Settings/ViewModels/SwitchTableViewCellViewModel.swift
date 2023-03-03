//
//  SwitchTableViewCellViewModel.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 01.06.2020.
//

import UIKit

struct SwitchTableViewCellViewModel {
    let titleText: String
    let icon: UIImage
    let value: Bool

    var titleFont: UIFont = Fonts.regular(size: 14)
    var titleTextColor: UIColor = Configuration.Color.Semantic.tableViewCellPrimaryFont
}

extension SwitchTableViewCellViewModel: Hashable {
    static func == (lhs: SwitchTableViewCellViewModel, rhs: SwitchTableViewCellViewModel) -> Bool {
        return lhs.titleText == rhs.titleText && lhs.icon == rhs.icon && lhs.value == rhs.value
    }
}
