// Copyright © 2021 Stormbird PTE. LTD.

import UIKit

struct PromptViewModel {
    let title: String
    let description: String
    let buttonTitle: String

    var backgroundColor: UIColor {
        ConfigurationLif3.Color.Semantic.backgroundClear
    }

    var footerBackgroundColor: UIColor {
        ConfigurationLif3.Color.Semantic.defaultViewBackground
    }
}
