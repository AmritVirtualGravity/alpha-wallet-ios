// Copyright © 2018 Stormbird PTE. LTD.

import UIKit

struct AssetDefinitionsOverridesViewCellViewModel: Hashable {
    let url: URL
    let fileExtension: String

    init(url: URL, fileExtension: String) {
        self.url = url
        self.fileExtension = fileExtension
    }

    var text: String {
        return url.lastPathComponent
    }

    let backgroundColor = ConfigurationLif3.Color.Semantic.defaultViewBackground
    let textColor = ConfigurationLif3.Color.Semantic.defaultForegroundText
    let textFont = Fonts.regular(size: 18)
    let textLineBreakMode = NSLineBreakMode.byTruncatingMiddle
}
