// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Combine
import AlphaWalletFoundation

struct SettingsViewModelInput {
    let willAppear: AnyPublisher<Void, Never>
    let appProtectionSelection: AnyPublisher<(indexPath: IndexPath, isOn: Bool), Never>
    let blockscanChatUnreadCount: AnyPublisher<Int?, Never>
}

struct SettingsViewModelOutput {
    let viewState: AnyPublisher<SettingsViewModel.ViewState, Never>
    let askToSetPasscode: AnyPublisher<Void, Never>
}

final class SettingsViewModel {
    private let account: Wallet
    private var assignedNameOrEns: String?
    private var config: Config
    private let keystore: Keystore
    private let analytics: AnalyticsLogger
    private let getWalletName: GetWalletName
    private var passcodeTitle: String {
        switch BiometryAuthenticationType.current {
        case .faceID, .touchID:
            return R.string.localizable.settingsBiometricsEnabledLabelTitle(BiometryAuthenticationType.current.title)
        case .none:
            return R.string.localizable.settingsBiometricsDisabledLabelTitle()
        }
    }
    private let lock: Lock
    private var hideTokenTitle: String {
        return R.string.localizable.settingsHideTokenTitle()
    }

    private (set) var sections: [SettingsSection] = []

    init(account: Wallet, keystore: Keystore, lock: Lock, config: Config, analytics: AnalyticsLogger, domainResolutionService: DomainResolutionServiceType) {
        self.account = account
        self.config = config
        self.keystore = keystore
        self.analytics = analytics
        self.lock = lock
        self.getWalletName = GetWalletName(domainResolutionService: domainResolutionService)
    }

    func heightForRow(at indexPath: IndexPath, fallbackHeight height: CGFloat) -> CGFloat {
        switch sections[indexPath.section] {
        case .wallet(let rows):
            let row = rows[indexPath.row]
            switch row {
            case .changeWallet:
                return Style.TableView.ChangeWalletCell.height
            default:
                return height
            }
        default:
            return height
        }
    }

    func transform(input: SettingsViewModelInput) -> SettingsViewModelOutput {
        let askToSetPasscode = self.askToSetPasscodeOrDeleteExisted(trigger: input.appProtectionSelection)

        //NOTE: Refresh wallet name or ens when view will appear called, cancel prev. one if in loading proc.
        let assignedNameOrEns = self.assignedNameOrEns(appear: input.willAppear)
        let blockscanChatUnreadCount = Publishers.Merge(Just<Int?>(nil), input.blockscanChatUnreadCount)
        let reload = Publishers.Merge3(Just<Void>(()), input.willAppear, assignedNameOrEns)

        let sections = Publishers.CombineLatest(reload, blockscanChatUnreadCount)
            .map { [account, keystore] _, blockscanChatUnreadCount -> [SettingsViewModel.SectionViewModel] in
                let sections = SettingsViewModel.functional.computeSections(account: account, keystore: keystore, blockscanChatUnreadCount: blockscanChatUnreadCount)
                return sections.indices.map { sectionIndex -> SettingsViewModel.SectionViewModel in
                    var views: [ViewType] = []
                    guard sections[sectionIndex].numberOfRows > 0 else {
                        return .init(section: sections[sectionIndex], views: [])
                    }

                    for rowIndex in 0 ..< sections[sectionIndex].numberOfRows {
                        let indexPath = IndexPath(item: rowIndex, section: sectionIndex)
                        let view = self.view(for: indexPath, sections: sections)

                        views.append(view)
                    }

                    return .init(section: sections[sectionIndex], views: views)
                }
            }.handleEvents(receiveOutput: { self.sections = $0.map { $0.section } })

        let badge = blockscanChatUnreadCount
            .map { value -> String? in
                if let unreadCount = value, unreadCount > 0 {
                    return String(unreadCount)
                } else {
                    return nil
                }
            }.removeDuplicates()

        let viewState = Publishers.CombineLatest(sections, badge)
            .map { sections, badge -> SettingsViewModel.ViewState in
                let snapshot = self.buildSnapshot(for: sections)
                return SettingsViewModel.ViewState(snapshot: snapshot, badge: badge)
            }.eraseToAnyPublisher()

        return .init(viewState: viewState, askToSetPasscode: askToSetPasscode)
    }

    /// Delates existed passcode if false received, sends void event when need to set a new passcode
    private func askToSetPasscodeOrDeleteExisted(trigger: AnyPublisher<(indexPath: IndexPath, isOn: Bool), Never>) -> AnyPublisher<Void, Never> {
        return trigger.compactMap { event -> Bool? in
            switch self.sections[event.indexPath.section] {
            case .system(let rows):
                switch rows[event.indexPath.row] {
                case .passcode: return event.isOn
                case .notifications, .selectActiveNetworks, .advanced: return nil
                case .hideToken: return nil
                case .theme: return nil
                }
            case .help, .tokenStandard, .version, .wallet: return nil
            }
        }.compactMap { [lock, analytics] isOn -> Void? in
            analytics.setUser(property: Analytics.UserProperties.isAppPasscodeOrBiometricProtectionEnabled, value: isOn)
            if isOn {
                return ()
            } else {
                lock.deletePasscode()
                return nil
            }
        }.eraseToAnyPublisher()
    }

    private func assignedNameOrEns(appear: AnyPublisher<Void, Never>) -> AnyPublisher<Void, Never> {
        return appear
            .flatMapLatest { [account, getWalletName] _ in getWalletName.assignedNameOrEns(for: account.address) }
            .handleEvents(receiveOutput: { self.assignedNameOrEns = $0 })
            .prepend(nil)
            .removeDuplicates()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    private func buildSnapshot(for viewModels: [SettingsViewModel.SectionViewModel]) -> SettingsViewModel.Snapshot {
        var snapshot = NSDiffableDataSourceSnapshot<SettingsSection, SettingsViewModel.ViewType>()
        let sections = viewModels.map { $0.section }
        snapshot.appendSections(sections)
        for each in viewModels {
            snapshot.appendItems(each.views, toSection: each.section)
        }

        return snapshot
    }

    private func addressReplacedWithEnsOrWalletName(_ ensOrWalletName: String? = nil) -> String {
        if let ensOrWalletName = ensOrWalletName {
            return "\(ensOrWalletName) | \(account.address.truncateMiddle)"
        } else {
            return account.address.truncateMiddle
        }
    }

    private func view(for indexPath: IndexPath, sections: [SettingsViewModel.SettingsSection]) -> ViewType {
        switch sections[indexPath.section] {
        case .system(let rows):
            let row = rows[indexPath.row]
            switch row {
            case .passcode:
                return .passcode(.init(titleText: passcodeTitle, icon: R.image.biometrics()!, value: lock.isPasscodeSet))
            case .hideToken:
                return .hideToken(.init(titleText: hideTokenTitle, icon: R.image.iconHideToken()!, value: UserDefaults.standard.bool(forKey: "HideToken")))
            case .notifications, .selectActiveNetworks, .advanced:
                return .cell(.init(settingsSystemRow: row))
            case .theme:
                let usrDefault = UserDefaults.standard
                return .theme(.init(titleText: R.string.localizable.settingsSupportDarkMode(), icon: R.image.biometrics()!, value: usrDefault.bool(forKey: "DarkModeOn")))
            }
        case .help:
            return .cell(.init(titleText: R.string.localizable.settingsSupportTitle(), icon: R.image.support()!))
        case .wallet(let rows):
            let row = rows[indexPath.row]
            switch row {
            case .changeWallet:
                return .cell(.init(titleText: row.title, subTitleText: addressReplacedWithEnsOrWalletName(assignedNameOrEns), icon: row.icon))
            case .backup:
                let walletSecurityLevel = PromptBackupCoordinator(keystore: keystore, wallet: account, config: .init(), analytics: analytics).securityLevel
                let accessoryView = walletSecurityLevel.flatMap { WalletSecurityLevelIndicator(level: $0) }
                return .cell(.init(titleText: row.title, subTitleText: nil, icon: row.icon, accessoryType: .disclosureIndicator, accessoryView: accessoryView))
            case .showMyWallet, .showSeedPhrase, .walletConnect, .nameWallet, .blockscanChat:
                return .cell(.init(settingsWalletRow: row))
            }
        case .tokenStandard, .version:
            return .undefined
        }
    }
}

extension SettingsViewModel {
    typealias Snapshot = NSDiffableDataSourceSnapshot<SettingsViewModel.SettingsSection, SettingsViewModel.ViewType>
    typealias DataSource = UITableViewDiffableDataSource<SettingsViewModel.SettingsSection, SettingsViewModel.ViewType>

    enum functional {}

    struct SectionViewModel {
        let section: SettingsViewModel.SettingsSection
        let views: [SettingsViewModel.ViewType]
    }

    enum ViewType {
        case passcode(SwitchTableViewCellViewModel)
        case cell(SettingTableViewCellViewModel)
        case undefined
        case hideToken(HideTokenSwitchTableViewCellViewModel)
        case theme(SwitchTableViewCellViewModel)
    }

    struct ViewState {
        let animatingDifferences: Bool = false
        let title: String = R.string.localizable.aSettingsNavigationTitle()
        let snapshot: SettingsViewModel.Snapshot
        let badge: String?
    }

    enum SettingsWalletRow {
        case showMyWallet
        case changeWallet
        case backup
        case showSeedPhrase
        case walletConnect
        case nameWallet
        case blockscanChat(blockscanChatUnreadCount: Int?)
    }

    enum SettingsSystemRow: CaseIterable {
        case notifications
        case passcode
        case selectActiveNetworks
        case advanced
        case hideToken
        case theme
    }

    enum SettingsSection {
        case wallet(rows: [SettingsWalletRow])
        case system(rows: [SettingsSystemRow])
        case help
        case version(value: String)
        case tokenStandard(value: String)
    }
}

extension SettingsViewModel.SectionViewModel: Equatable {
    static func == (lhs: SettingsViewModel.SectionViewModel, rhs: SettingsViewModel.SectionViewModel) -> Bool {
        return lhs.section == rhs.section && lhs.views == rhs.views
    }
}

extension SettingsViewModel.ViewType: Hashable {
    static func == (lhs: SettingsViewModel.ViewType, rhs: SettingsViewModel.ViewType) -> Bool {
        switch (lhs, rhs) {
        case (.undefined, .undefined):
            return true
        case (.passcode(let vm1), .passcode(let vm2)):
            return vm1 == vm2
        case (.cell(let vm1), .cell(let vm2)):
            return vm1 == vm2
        case (.hideToken(let vm1), .hideToken(let vm2)):
            return vm1 == vm2
        case (.undefined, .cell), (.undefined, .passcode), (.passcode, .undefined), (.cell, .passcode), (.cell, .undefined), (.passcode, .cell),
            (.undefined, .hideToken), (.hideToken, .undefined), (.passcode, .hideToken), (.hideToken, .passcode), (.cell, .hideToken), (.hideToken, .cell), (.cell, .theme), (.theme, .cell), (.undefined, .theme), (.theme, .undefined),  (.passcode, .theme), (.theme, .passcode), (.theme, .hideToken), (.hideToken, .theme):
            return false
        case (.theme(let vm1), .theme(let vm2)):
            return vm1 == vm2
        }
    }
}

extension SettingsViewModel.functional {
    fileprivate static func computeSections(account: Wallet, keystore: Keystore, blockscanChatUnreadCount: Int?) -> [SettingsViewModel.SettingsSection] {
        let walletRows: [SettingsViewModel.SettingsWalletRow]
        if account.allowBackup {
            if account.origin == .hd {
                // blockscanchat hidden for now.
                 walletRows = [.showMyWallet, .changeWallet, .backup, .showSeedPhrase, .nameWallet, .walletConnect]
//                walletRows = [.showMyWallet, .changeWallet, .backup, .showSeedPhrase, .nameWallet, .walletConnect, .blockscanChat(blockscanChatUnreadCount: blockscanChatUnreadCount)]
            } else {
                walletRows = [.showMyWallet, .changeWallet, .backup, .nameWallet, .walletConnect]
//                walletRows = [.showMyWallet, .changeWallet, .backup, .nameWallet, .walletConnect, .blockscanChat(blockscanChatUnreadCount: blockscanChatUnreadCount)]
            }
        } else {
            walletRows = [.showMyWallet, .changeWallet, .nameWallet, .walletConnect]
//            walletRows = [.showMyWallet, .changeWallet, .nameWallet, .walletConnect, .blockscanChat(blockscanChatUnreadCount: blockscanChatUnreadCount)]
        }
        let systemRows: [SettingsViewModel.SettingsSystemRow] = [.passcode, .selectActiveNetworks, .advanced, .hideToken, .theme]
        
        return [
            .wallet(rows: walletRows),
            .system(rows: systemRows),
            .help,
            .version(value: Bundle.main.fullVersion),
            .tokenStandard(value: "\(TokenScript.supportedTokenScriptNamespaceVersion)")
        ]
    }
}

extension SettingsViewModel.SettingsWalletRow {
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
        case .walletConnect:
            return R.string.localizable.settingsWalletConnectButtonTitle()
        case .nameWallet:
            return R.string.localizable.settingsWalletRename()
        case .blockscanChat(let blockscanChatUnreadCount):
            if let blockscanChatUnreadCount = blockscanChatUnreadCount, blockscanChatUnreadCount > 0 {
                return "\(R.string.localizable.settingsBlockscanChat()) (\(blockscanChatUnreadCount))"
            } else {
                return R.string.localizable.settingsBlockscanChat()
            }
        }
    }

    var icon: UIImage {
        switch self {
        case .showMyWallet:
            return R.image.walletAddress()!
        case .changeWallet:
            return R.image.changeWallet()!
        case .backup:
            return R.image.backupCircle()!
        case .showSeedPhrase:
            return R.image.iconsSettingsSeed2()!
        case .walletConnect:
            return R.image.iconsSettingsWalletConnect()!
        case .nameWallet:
            return R.image.iconsSettingsDisplayedEns()!
        case .blockscanChat:
            return R.image.settingsBlockscanChat()!
        }
    }
}

extension SettingsViewModel.SettingsWalletRow: Hashable {
    static func == (lhs: SettingsViewModel.SettingsWalletRow, rhs: SettingsViewModel.SettingsWalletRow) -> Bool {
        switch (lhs, rhs) {
        case (.showMyWallet, .showMyWallet):
            return true
        case (.changeWallet, .changeWallet):
            return true
        case (.backup, .backup):
            return true
        case (.showSeedPhrase, .showSeedPhrase):
            return true
        case (.walletConnect, .walletConnect):
            return true
        case (.nameWallet, .nameWallet):
            return true
        case (.blockscanChat(let c1), .blockscanChat(let c2)):
            return c1 == c2
        case (.blockscanChat, .walletConnect), (.blockscanChat, .showSeedPhrase), (.blockscanChat, .showMyWallet), (.blockscanChat, .changeWallet), (.blockscanChat, .backup):
            return false
        case (.nameWallet, .walletConnect), (.nameWallet, .showSeedPhrase), (.nameWallet, .backup), (.nameWallet, .changeWallet), (.blockscanChat, .nameWallet), (.nameWallet, .showMyWallet):
            return false
        case (.walletConnect, .nameWallet), (.walletConnect, .showSeedPhrase), (.walletConnect, .backup), (.walletConnect, .changeWallet), (.walletConnect, .showMyWallet), (.nameWallet, .blockscanChat):
            return false
        case (.showSeedPhrase, .walletConnect), (.showSeedPhrase, .backup), (.showSeedPhrase, .changeWallet), (.showSeedPhrase, .showMyWallet), (.walletConnect, .blockscanChat):
            return false
        case (.backup, .nameWallet), (.backup, .walletConnect), (.backup, .showSeedPhrase), (.backup, .changeWallet), (.backup, .showMyWallet), (.showSeedPhrase, .blockscanChat), (.showSeedPhrase, .nameWallet):
            return false
        case (.changeWallet, .nameWallet), (.changeWallet, .walletConnect), (.changeWallet, .showSeedPhrase), (.changeWallet, .backup), (.changeWallet, .showMyWallet), (.backup, .blockscanChat):
            return false
        case (.showMyWallet, .blockscanChat), (.showMyWallet, .nameWallet), (.showMyWallet, .walletConnect), (.showMyWallet, .showSeedPhrase), (.showMyWallet, .backup), (.showMyWallet, .changeWallet), (.changeWallet, .blockscanChat):
            return false
        }
    }
}

extension SettingsViewModel.SettingsSystemRow {

    var title: String {
        switch self {
        case .notifications:
            return R.string.localizable.settingsNotificationsTitle()
        case .passcode:
            return R.string.localizable.settingsPasscodeTitle()
        case .selectActiveNetworks:
            return R.string.localizable.settingsSelectActiveNetworksTitle()
        case .advanced:
            return R.string.localizable.advanced()
        case .hideToken:
            return R.string.localizable.settingsPasscodeTitle()
        case .theme:
            return R.string.localizable.settingsPasscodeTitle()
        }
    }

    var icon: UIImage {
        switch self {
        case .notifications:
            return R.image.notificationsCircle()!
        case .passcode:
            return R.image.biometrics()!
        case .selectActiveNetworks:
            return R.image.networksCircle()!
        case .advanced:
            return R.image.developerMode()!
        case .hideToken:
            return R.image.biometrics()!
        case .theme:
            return R.image.biometrics()!
        }
    }
}

extension SettingsViewModel.SettingsSection {
    var title: String {
        switch self {
        case .wallet:
            return R.string.localizable.settingsSectionWalletTitle().uppercased()
        case .system:
            return R.string.localizable.settingsSectionSystemTitle().uppercased()
        case .help:
            return R.string.localizable.settingsSectionHelpTitle().uppercased()
        case .version:
            return R.string.localizable.settingsVersionLabelTitle()
        case .tokenStandard:
            return R.string.localizable.settingsTokenScriptStandardTitle()
        }
    }

    var numberOfRows: Int {
        switch self {
        case .wallet(let rows):
            return rows.count
        case .help:
            return 1
        case .system(let rows):
            return rows.count
        case .version, .tokenStandard:
            return 0
        }
    }
}

extension SettingsViewModel.SettingsSection: Hashable {
    static func == (lhs: SettingsViewModel.SettingsSection, rhs: SettingsViewModel.SettingsSection) -> Bool {
        switch (lhs, rhs) {
        case (.help, .help):
            return true
        case (.version, .version):
            return true
        case (.tokenStandard, .tokenStandard):
            return true
        case (.wallet(let r1), .wallet(let r2)):
            return r1 == r2
        case (.system(let r1), .system(let r2)):
            return r1 == r2
        case (.wallet, .tokenStandard), (.wallet, .version), (.wallet, .help), (.wallet, .system), (.system, .tokenStandard), (.system, .version), (.system, .help), (.system, .wallet):
            return false
        case (.version, .help), (.version, .system), (.version, .wallet), (.tokenStandard, .version), (.tokenStandard, .help), (.tokenStandard, .system), (.tokenStandard, .wallet):
            return false
        case (.help, .tokenStandard), (.help, .version), (.help, .system), (.help, .wallet), (.version, .tokenStandard):
            return false
        }
    }
}

extension BiometryAuthenticationType {
    var title: String {
        switch self {
        case .faceID: return R.string.localizable.faceId()
        case .touchID: return R.string.localizable.touchId()
        case .none: return ""
        }
    }
}
