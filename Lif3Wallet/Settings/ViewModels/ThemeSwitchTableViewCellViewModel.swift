

import UIKit

struct ThemeSwitchTableViewCellViewModel {
    let titleText: String
    let icon: UIImage
    let value: Bool

    var titleFont: UIFont = Fonts.regular(size: 14)
    var titleTextColor: UIColor = ConfigurationLif3.Color.Semantic.tableViewCellPrimaryFont
}

extension ThemeSwitchTableViewCellViewModel: Hashable {
    static func == (lhs: ThemeSwitchTableViewCellViewModel, rhs: ThemeSwitchTableViewCellViewModel) -> Bool {
        return lhs.titleText == rhs.titleText && lhs.icon == rhs.icon && lhs.value == rhs.value
    }
}
