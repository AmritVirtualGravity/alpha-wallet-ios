

import UIKit

struct ThemeSwitchTableViewCellViewModel {
    let titleText: String
    let icon: UIImage
    let value: Bool

    var titleFont: UIFont = Fonts.regular(size: 17)
    var titleTextColor: UIColor = Configuration.Color.Semantic.tableViewCellPrimaryFont
}

extension ThemeSwitchTableViewCellViewModel: Hashable {
    static func == (lhs: ThemeSwitchTableViewCellViewModel, rhs: ThemeSwitchTableViewCellViewModel) -> Bool {
        return lhs.titleText == rhs.titleText && lhs.icon == rhs.icon && lhs.value == rhs.value
    }
}
