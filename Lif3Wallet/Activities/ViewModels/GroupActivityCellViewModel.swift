// Copyright © 2021 Stormbird PTE. LTD.

import UIKit

struct GroupActivityCellViewModel {
    enum GroupType {
        case swap
        case unknown
    }

    let groupType: GroupType

    var contentsBackgroundColor: UIColor {
        ConfigurationLif3.Color.Semantic.tableViewCellBackground
    }

    var backgroundColor: UIColor {
        ConfigurationLif3.Color.Semantic.tableViewCellBackground
    }

    var titleTextColor: UIColor {
        ConfigurationLif3.Color.Semantic.defaultForegroundText
    }

    var title: NSAttributedString {
        switch groupType {
        case .swap:
            return NSAttributedString(string: R.string.localizable.activityGroupTransactionSwap())
        case .unknown:
            return NSAttributedString(string: R.string.localizable.activityGroupTransactionUnknown())
        }
    }

    var leftMargin: CGFloat {
        DataEntry.Metric.sideMargin
    }
}
