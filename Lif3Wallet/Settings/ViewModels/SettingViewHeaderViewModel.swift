//
//  SettingViewHeaderViewModel.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 02.06.2020.
//

import UIKit

struct SettingViewHeaderViewModel {
    let titleText: String
    var detailsText: String?
    var titleTextFont: UIFont
    var showTopSeparator: Bool = true

    var titleTextColor: UIColor = ConfigurationLif3.Color.Semantic.tableViewCellPrimaryFont
    var detailsTextColor: UIColor = ConfigurationLif3.Color.Semantic.tableViewCellPrimaryFont
    var detailsTextFont: UIFont = Fonts.regular(size: 13)
//    var backgroundColor: UIColor = ConfigurationLif3.Color.Semantic.tableViewHeaderBackground
    var backgroundColor: UIColor = .clear
    
    var separatorColor: UIColor = ConfigurationLif3.Color.Semantic.tableViewSeparator
}

extension SettingViewHeaderViewModel {
    init(section: SettingsViewModel.SettingsSection) {
        titleText = section.title
        switch section {
        case .tokenStandard(let value), .version(let value):
            detailsText = value
            titleTextFont = Fonts.regular(size: 15)
            if case .tokenStandard = section {
                showTopSeparator = false
            }
        case .wallet, .system, .help, .social, .activity:
            titleTextFont = Fonts.semibold(size: 15)
        }
       
    }
}
