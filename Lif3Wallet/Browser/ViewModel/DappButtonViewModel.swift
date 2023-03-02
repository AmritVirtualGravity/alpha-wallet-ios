// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import UIKit

struct DappButtonViewModel {
    var font: UIFont? {
        return Fonts.semibold(size: 14)
    }

    var textColor: UIColor? {
        return ConfigurationLif3.Color.Semantic.defaultTitleText
    }

    var imageForEnabledMode: UIImage? {
        return image
    }

    var imageForDisabledMode: UIImage? {
        return image?.withMonoEffect
    }

    let image: UIImage?
    let title: String
}
