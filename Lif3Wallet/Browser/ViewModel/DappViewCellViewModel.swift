// Copyright © 2018 Stormbird PTE. LTD.
import Foundation
import UIKit
import AlphaWalletFoundation

struct DappViewCellViewModel: Hashable {
    let bookmark: BookmarkObject

    var imageUrl: URL? {
        Favicon.get(for: bookmark.url)
    }

    var title: String {
        bookmark.title
    }

    var domainName: String {
        bookmark.url?.host ?? ""
    }

    init(bookmark: BookmarkObject) {
        self.bookmark = bookmark
    }

    var fallbackImage: UIImage? {
        return R.image.iconsTokensPlaceholder()
    }

    var backgroundColor: UIColor {
        return ConfigurationLif3.Color.Semantic.defaultViewBackground
    }

    var imageViewShadowColor: UIColor {
        return ConfigurationLif3.Color.Semantic.shadow
    }

    var imageViewShadowOffset: CGSize {
        return DataEntry.Metric.DappsHome.Icon.shadowOffset
    }

    var imageViewShadowOpacity: Float {
        return DataEntry.Metric.DappsHome.Icon.shadowOpacity
    }

    var imageViewShadowRadius: CGFloat {
        return DataEntry.Metric.DappsHome.Icon.shadowRadius
    }

    var titleColor: UIColor {
        return ConfigurationLif3.Color.Semantic.defaultTitleText
    }

    var titleFont: UIFont {
        return Fonts.semibold(size: 14)
    }

    var domainNameColor: UIColor {
        return ConfigurationLif3.Color.Semantic.defaultViewBackground
    }

    var domainNameFont: UIFont {
        return Fonts.bold(size: 10)
    }
}
