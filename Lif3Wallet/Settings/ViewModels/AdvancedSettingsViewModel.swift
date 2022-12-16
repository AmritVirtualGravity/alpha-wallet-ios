//
//  AdvancedSettingsViewModel.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 01.06.2020.
//

import Foundation
import UIKit
import AlphaWalletFoundation
import Combine

struct AdvancedSettingsViewModelInput {
    let willAppear: AnyPublisher<Void, Never>
}

struct AdvancedSettingsViewModelOutput {
    let viewState: AnyPublisher<AdvancedSettingsViewModel.ViewState, Never>
}

class AdvancedSettingsViewModel {
    private let wallet: Wallet
    private let config: Config
    private (set) var rows: [AdvancedSettingsViewModel.AdvancedSettingsRow] = []
    private let features: Features = .default
    let largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode = .never
    
    init(wallet: Wallet, config: Config) {
        self.wallet = wallet
        self.config = config
    }

    func transform(input: AdvancedSettingsViewModelInput) -> AdvancedSettingsViewModelOutput {
        let viewState = input.willAppear
            .map { [wallet, features] _ in AdvancedSettingsViewModel.functional.computeSections(wallet: wallet, features: features) }
            .handleEvents(receiveOutput: { self.rows = $0 })
            .map { $0.map { self.buildCellViewModel(for: $0) } }
            .map { AdvancedSettingsViewModel.SectionViewModel(section: .rows, views: $0) }
            .map { self.buildSnapshot(for: [$0]) }
            .map { ViewState(snapshot: $0) }
            .eraseToAnyPublisher()

        return .init(viewState: viewState)
    }

    private func buildCellViewModel(for row: AdvancedSettingsViewModel.AdvancedSettingsRow) -> SettingTableViewCellViewModel {
        switch row {
        case .analytics, .changeCurrency, .changeLanguage, .clearBrowserCache, .tools, .tokenScript, .exportJSONKeystore, .features, .hideToken, .theme:
            return .init(titleText: row.title, subTitleText: nil, icon: row.icon)
        case .usePrivateNetwork:
            let provider = config.sendPrivateTransactionsProvider
            return .init(titleText: row.title, subTitleText: provider?.title, icon: provider?.icon ?? row.icon)
        }
    }

    private func buildSnapshot(for viewModels: [AdvancedSettingsViewModel.SectionViewModel]) -> AdvancedSettingsViewModel.Snapshot {
        var snapshot = AdvancedSettingsViewModel.Snapshot()
        let sections = viewModels.map { $0.section }
        snapshot.appendSections(sections)
        for each in viewModels {
            snapshot.appendItems(each.views, toSection: each.section)
        }

        return snapshot
    }
}

extension AdvancedSettingsViewModel {
    class DataSource: UITableViewDiffableDataSource<AdvancedSettingsViewModel.Section, SettingTableViewCellViewModel> {}
    typealias Snapshot = NSDiffableDataSourceSnapshot<AdvancedSettingsViewModel.Section, SettingTableViewCellViewModel>

    enum functional {}
    
    enum Section: Int, Hashable, CaseIterable {
        case rows
    }

    struct SectionViewModel {
        let section: AdvancedSettingsViewModel.Section
        let views: [SettingTableViewCellViewModel]
    }

    struct ViewState {
        let title: String = R.string.localizable.settingsPreferencesTitle()
        let animatingDifferences: Bool = false
        let snapshot: AdvancedSettingsViewModel.Snapshot
    }

    enum AdvancedSettingsRow: CaseIterable {
        case tools
        case clearBrowserCache
        case tokenScript
        case changeLanguage
        case changeCurrency
        case analytics
        case usePrivateNetwork
        case exportJSONKeystore
        case features
        case hideToken
        case theme
    }
}

extension AdvancedSettingsViewModel.functional {
    fileprivate static func computeSections(wallet: Wallet, features: Features) -> [AdvancedSettingsViewModel.AdvancedSettingsRow] {
        let canExportToJSONKeystore = features.isAvailable(.isExportJsonKeystoreEnabled) && wallet.isReal()
        return [
            .clearBrowserCache,
            //tokenscript and private network hidden for now. 
//            .tokenScript,
//            features.isAvailable(.isUsingPrivateNetwork) ? .usePrivateNetwork : nil,
            features.isAvailable(.isAnalyticsUIEnabled) ? .analytics : nil,
            features.isAvailable(.isLanguageSwitcherEnabled) ? .changeLanguage: nil,
            features.isAvailable(.isChangeCurrencyEnabled) ? .changeCurrency : nil,
            canExportToJSONKeystore ? .exportJSONKeystore : nil,
            .tools,
            (Environment.isDebug || Environment.isTestFlight) ? .features : nil,
            .hideToken,
            .theme
        ].compactMap { $0 }
    }
}

fileprivate extension AdvancedSettingsViewModel.AdvancedSettingsRow {

    var title: String {
        switch self {
        case .tools:
            return R.string.localizable.aSettingsTools()
        case .clearBrowserCache:
            return R.string.localizable.aSettingsContentsClearDappBrowserCache()
        case .tokenScript:
            return R.string.localizable.aHelpAssetDefinitionOverridesTitle()
        case .changeLanguage:
            return R.string.localizable.settingsLanguageButtonTitle()
        case .changeCurrency:
            return R.string.localizable.settingsChangeCurrencyTitle()
        case .analytics:
            return R.string.localizable.settingsAnalitycsTitle()
        case .usePrivateNetwork:
            return R.string.localizable.settingsChooseSendPrivateTransactionsProviderButtonTitle()
        case .exportJSONKeystore:
            return R.string.localizable.settingsAdvancedExportJSONKeystoreTitle()
        case .features:
            return R.string.localizable.advancedSettingsFeaturesTitle()
        case .hideToken:
            return R.string.localizable.settingsHideTokenTitle()
        case .theme:
            return R.string.localizable.settingsSupportDarkMode()
        }
    }

    var icon: UIImage {
        switch self {
        case .tools:
            return R.image.developerMode()!
        case .clearBrowserCache:
            return R.image.settings_clear_dapp_cache()!
        case .tokenScript:
            return R.image.settings_tokenscript_overrides()!
        case .changeLanguage:
            return R.image.settings_language()!
        case .changeCurrency:
            return R.image.settings_currency()!
        case .analytics:
            return R.image.settings_analytics()!
        case .usePrivateNetwork:
            return R.image.iconsSettingsEthermine()!
        case .exportJSONKeystore:
            return R.image.iconsSettingsJson()!
        case .features:
            return R.image.ticket_bundle_checked()!
        case .hideToken:
            return R.image.iconHideToken()!
        case .theme:
            return R.image.biometrics()!
        }
    }
}

fileprivate extension Wallet {
    func isReal() -> Bool {
        return type == .real(address)
    }
}

extension SendPrivateTransactionsProvider {
    var title: String {
        switch self {
        case .ethermine:
            return R.string.localizable.sendPrivateTransactionsProviderEtheremine()
        case .eden:
            return R.string.localizable.sendPrivateTransactionsProviderEden()
        }
    }

    var icon: UIImage {
        switch self {
        case .ethermine:
            return R.image.iconsSettingsEthermine()!
        case .eden:
            return R.image.iconsSettingsEden()!
        }
    }
}
