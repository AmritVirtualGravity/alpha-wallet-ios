//
//  AdvancedSettingsViewController.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 01.06.2020.
//

import UIKit
import AlphaWalletFoundation
import Combine

protocol AdvancedSettingsViewControllerDelegate: AnyObject {
    func moreSelected(in controller: AdvancedSettingsViewController)
    func clearBrowserCacheSelected(in controller: AdvancedSettingsViewController)
    func tokenScriptSelected(in controller: AdvancedSettingsViewController)
    func changeLanguageSelected(in controller: AdvancedSettingsViewController)
    func changeCurrencySelected(in controller: AdvancedSettingsViewController)
    func analyticsSelected(in controller: AdvancedSettingsViewController)
    func usePrivateNetworkSelected(in controller: AdvancedSettingsViewController)
    func exportJSONKeystoreSelected(in controller: AdvancedSettingsViewController)
    func featuresSelected(in controller: AdvancedSettingsViewController)
}

class AdvancedSettingsViewController: UIViewController {
    private let viewModel: AdvancedSettingsViewModel
    private lazy var tableView: UITableView = {
        let tableView = UITableView.insetGroped
        tableView.register(SettingTableViewCell.self)
        tableView.register(HideTokenSwitchTableViewCell.self)
        tableView.register(ThemeSwitchTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self

        return tableView
    }()
    private let willAppear = PassthroughSubject<Void, Never>()
    private var cancellable = Set<AnyCancellable>()
    private lazy var dataSource = makeDataSource()

    weak var delegate: AdvancedSettingsViewControllerDelegate?

    init(viewModel: AdvancedSettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.anchorsIgnoringBottomSafeArea(to: view)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Configuration.Color.Semantic.defaultViewBackground
        
        navigationItem.title = R.string.localizable.settingsPreferencesTitle()

//        bind(viewModel: viewModel)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        willAppear.send(())
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    private func bind(viewModel: AdvancedSettingsViewModel) {
        let input = AdvancedSettingsViewModelInput(willAppear: willAppear.eraseToAnyPublisher())
        let output = viewModel.transform(input: input)

        output.viewState
            .sink { [dataSource, navigationItem] viewState in
                navigationItem.title = viewState.title
                dataSource.apply(viewState.snapshot, animatingDifferences: viewState.animatingDifferences)
            }.store(in: &cancellable)
    }
}

fileprivate extension AdvancedSettingsViewController {
    private func makeDataSource() -> AdvancedSettingsViewModel.DataSource {
        return AdvancedSettingsViewModel.DataSource(tableView: tableView, cellProvider: { tableView, indexPath, viewModel in
            switch self.viewModel.rows[indexPath.row] {
            case .hideToken:
                let cell: HideTokenSwitchTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                let vm = HideTokenSwitchTableViewCellViewModel(titleText: viewModel.titleText, icon: viewModel.icon!, value: UserDefaults.standard.bool(forKey: "HideToken"))
                cell.configure(viewModel: vm)
                cell.delegate = self
                return cell
            case .theme:
                let cell: ThemeSwitchTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                let vm = ThemeSwitchTableViewCellViewModel(titleText: viewModel.titleText, icon: viewModel.icon!, value: UserDefaults.standard.bool(forKey: "DarkModeOn"))
                cell.configure(viewModel: vm)
                cell.delegate = self
                return cell
            default:
                let cell: SettingTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.configure(viewModel: viewModel)
                return cell
            }
        })
    }
}

extension AdvancedSettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.advancedSettingSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewModel.advancedSettingSections[section] {
        case .displays(let rows):
            return rows.count
        case .browser(let rows):
            return rows.count
        case .analytics(let rows):
            return rows.count
        case .tools(let rows):
            return rows.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var vm = SettingTableViewCellViewModel(titleText: "", icon: UIImage())
        
        let section = viewModel.advancedSettingSections[indexPath.section]
        switch section {
        case .displays(rows: let rows):
            switch rows[indexPath.row] {
            case .hideToken:
                let cell: HideTokenSwitchTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                let vm = HideTokenSwitchTableViewCellViewModel(titleText: R.string.localizable.settingsHideTokenTitle(),
                                                               icon: R.image.iconHideToken()!,
                                                               value: UserDefaults.standard.bool(forKey: "HideToken"))
                cell.configure(viewModel: vm)
                cell.delegate = self
                return cell
            case .theme:
                let cell: ThemeSwitchTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                let vm = ThemeSwitchTableViewCellViewModel(titleText: R.string.localizable.settingsSupportDarkMode(),
                                                           icon: R.image.setting_dark_mode()!,
                                                           value: UserDefaults.standard.bool(forKey: "DarkModeOn"))
                cell.configure(viewModel: vm)
                cell.delegate = self
                return cell
            case .changeLanguage:
                vm = viewModel.buildCellViewModel(for: .changeLanguage)
            case .changeCurrency:
                vm = viewModel.buildCellViewModel(for: .changeCurrency)
            default:
                 break
            }
        case .browser:
            vm = viewModel.buildCellViewModel(for: .clearBrowserCache)
        case .analytics:
            let cell: ThemeSwitchTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            let vm = ThemeSwitchTableViewCellViewModel(titleText: R.string.localizable.settingsAnalitycsTitle(),
                                                       icon: R.image.share_analytics()!,
                                                       value: viewModel.config.sendAnalyticsEnabled ?? true)
            cell.configure(viewModel: vm)
            cell.switchClosure = { [weak self] boolValue in
                guard let self = self else { return }
                self.viewModel.config.sendAnalyticsEnabled = boolValue
            }
            return cell
        case .tools:
            vm = viewModel.buildCellViewModel(for: .tools)
        }
        
        let cell: SettingTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(viewModel: vm)
        return cell
    }
    
}

extension AdvancedSettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

   
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        .leastNormalMagnitude
        return 34
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        nil
    }

    //Hide the footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        switch viewModel.rows[indexPath.row] {
//        case .tools:
//            delegate?.moreSelected(in: self)
//        case .clearBrowserCache:
//            delegate?.clearBrowserCacheSelected(in: self)
//        case .tokenScript:
//            delegate?.tokenScriptSelected(in: self)
//        case .changeLanguage:
//            delegate?.changeLanguageSelected(in: self)
//        case .changeCurrency:
//            delegate?.changeCurrencySelected(in: self)
//        case .analytics:
//            delegate?.analyticsSelected(in: self)
//        case .usePrivateNetwork:
//            delegate?.usePrivateNetworkSelected(in: self)
//        case .exportJSONKeystore:
//            delegate?.exportJSONKeystoreSelected(in: self)
//        case .features:
//            delegate?.featuresSelected(in: self)
//        case .hideToken, .theme:
//            break
//        }
        
        let section = viewModel.advancedSettingSections[indexPath.section]
        
        switch section {
        case .displays(let rows):
            switch rows[indexPath.row] {
            case .changeLanguage:
                delegate?.changeLanguageSelected(in: self)
            case .changeCurrency:
                delegate?.changeCurrencySelected(in: self)
            default:
                 break
            }
        case .browser:
            delegate?.clearBrowserCacheSelected(in: self)
        case .analytics:
//            delegate?.analyticsSelected(in: self)
            break
        case .tools:
            delegate?.moreSelected(in: self)
        }
    }
}

extension AdvancedSettingsViewController: HideTokenSwitchTableViewCellDelegate {

    func cell(_ cell: HideTokenSwitchTableViewCell, switchStateChanged isOn: Bool) {
        self.view.isUserInteractionEnabled = false
        let usrDefault = UserDefaults.standard
        if (usrDefault.bool(forKey: "HideToken") == true) {
            usrDefault.set(false, forKey: "HideToken")
        } else {
            usrDefault.set(true, forKey: "HideToken")
        }
        NotificationCenter.default.post(name: Notification.Name("HideTokenNotification"), object: nil)
        self.view.isUserInteractionEnabled = true
    }
    
}

extension AdvancedSettingsViewController: ThemeSwitchTableViewCellDelegate {

    func didChangeTheme(_ cell: ThemeSwitchTableViewCell, switchStateChanged isOn: Bool) {
        self.view.isUserInteractionEnabled = false
        let userDefault = UserDefaults.standard
        let window = UIApplication.shared.windows.first
        if (userDefault.bool(forKey: "DarkModeOn") == true) {
            window?.overrideUserInterfaceStyle = .light
            userDefault.set(false, forKey: "DarkModeOn")
        } else {
            window?.overrideUserInterfaceStyle = .dark
            userDefault.set(true, forKey: "DarkModeOn")
        }
        self.view.isUserInteractionEnabled = true
    }
    
}
