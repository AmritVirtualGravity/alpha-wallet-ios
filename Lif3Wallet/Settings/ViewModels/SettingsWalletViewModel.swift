// Copyright © 2022 Stormbird PTE. LTD.

import UIKit
import AlphaWalletFoundation

class SettingsWalletViewModel {
    private var config: Config
    private var rows: [SettingsWalletViewModel.walletRows] = SettingsWalletViewModel.walletRows.allCases

    var title: String = R.string.localizable.settingsSectionWalletTitle()
    var largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode = .never

    init(config: Config) {
        self.config = config
    }

    func numberOfRows() -> Int {
        return rows.count
    }

    func viewModel(for indexPath: IndexPath) -> SettingTableViewCellViewModel {
        let row = rows[indexPath.row]
        return .init(titleText: row.title, subTitleText: nil, icon: row.icon)
    }

    func row(for indexPath: IndexPath) -> SettingsWalletViewModel.walletRows {
        return rows[indexPath.row]
    }
}


extension SettingsWalletViewModel {
    enum walletRows: Int, CaseIterable {
        case showMyWallet
        case changeWallet
        case backup
        case showSeedPhrase
        case nameWallet
        case exportJSONKeystore
        
        var title: String {
            switch self {
            case .showMyWallet:
                return R.string.localizable.settingsShowMyWalletTitle()
            case .changeWallet:
                return R.string.localizable.settingsChangeWalletTitle()
            case .backup:
                return R.string.localizable.settingsBackupWalletButtonTitle()
            case .showSeedPhrase:
                return R.string.localizable.settingsShowSeedPhraseButtonTitle()
            case .nameWallet:
                return R.string.localizable.settingsWalletRename()
            case .exportJSONKeystore:
                return R.string.localizable.settingsAdvancedExportJSONKeystoreTitle()
            }
           
        }

        var icon: UIImage {
            switch self {
            case .showMyWallet:
                return R.image.walletAddress()!
            case .changeWallet:
                return R.image.changeWallet()!
            case .showSeedPhrase:
                return R.image.iconsSettingsSeed2()!
            case .nameWallet:
                return R.image.iconsSettingsDisplayedEns()!
            case .backup:
                return R.image.backupCircle()!
            case .exportJSONKeystore:
                return R.image.iconsSettingsJson()!
            }
        }
    }
}
