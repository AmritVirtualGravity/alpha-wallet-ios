

import UIKit

struct HideTokenSwitchTableViewCellViewModel {
    let titleText: String
    let icon: UIImage
    let value: Bool

    var titleFont: UIFont = Fonts.regular(size: 14)
    var titleTextColor: UIColor = ConfigurationLif3.Color.Semantic.tableViewCellPrimaryFont
}

extension HideTokenSwitchTableViewCellViewModel: Hashable {
    static func == (lhs: HideTokenSwitchTableViewCellViewModel, rhs: HideTokenSwitchTableViewCellViewModel) -> Bool {
        return lhs.titleText == rhs.titleText && lhs.icon == rhs.icon && lhs.value == rhs.value
    }
}
