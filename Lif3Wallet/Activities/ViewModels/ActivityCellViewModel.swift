// Copyright © 2020 Stormbird PTE. LTD.

import Foundation
import BigInt
import AlphaWalletFoundation

struct ActivityCellViewModel {
    private var server: RPCServer {
        activity.server
    }

    let activity: Activity

    var contentsBackgroundColor: UIColor {
        ConfigurationLif3.Color.Semantic.tableViewCellBackground
    }

    var contentsCornerRadius: CGFloat {
        return DataEntry.Metric.CornerRadius.box
    }

    var backgroundColor: UIColor {
        return ConfigurationLif3.Color.Semantic.tableViewCellBackground
    }
}
