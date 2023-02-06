// Copyright © 2018 Stormbird PTE. LTD.

import UIKit
import Combine
import AlphaWalletFoundation

protocol SettingsViewControllerDelegate: AnyObject, CanOpenURL {
    func advancedSettingsSelected(in controller: SettingsViewController)
    func changeWalletSelected(in controller: SettingsViewController)
    func myWalletAddressSelected(in controller: SettingsViewController)
    func backupWalletSelected(in controller: SettingsViewController)
    func showSeedPhraseSelected(in controller: SettingsViewController)
    func walletConnectSelected(in controller: SettingsViewController)
    func nameWalletSelected(in controller: SettingsViewController)
    func blockscanChatSelected(in controller: SettingsViewController)
    func activeNetworksSelected(in controller: SettingsViewController)
    func createPasswordSelected(in controller: SettingsViewController)
    func helpSelected(in controller: SettingsViewController)
    func securitySelected(in controller: SettingsViewController)
    func scanQrSelected(in controller: SettingsViewController)
    func mainWalletSelected(in controller: SettingsViewController)
    func activitySelected(in controller: SettingsViewController)
    func addContactSelected(in controller: SettingsViewController)
}

class SettingsViewController: UIViewController {
    private let promptBackupWalletViewHolder = UIView()
    private lazy var tableView: UITableView = {
        let tableView = UITableView.insetGroped
        tableView.register(SettingTableViewCell.self)
        tableView.register(SwitchTableViewCell.self)
        tableView.register(HideTokenSwitchTableViewCell.self)
        tableView.register(ThemeSwitchTableViewCell.self)
        tableView.separatorStyle = .singleLine
        tableView.estimatedRowHeight = DataEntry.Metric.anArbitraryRowHeightSoAutoSizingCellsWorkIniOS10
        tableView.delegate = self

        return tableView
    }()
    private lazy var dataSource = makeDataSource()
    private let willAppear = PassthroughSubject<Void, Never>()
    private let appProtectionSelection = PassthroughSubject<(indexPath: IndexPath, isOn: Bool), Never>()
    private let blockscanChatUnreadCount = PassthroughSubject<Int?, Never>()
    private var cancellable = Set<AnyCancellable>()
    private let viewModel: SettingsViewModel

    weak var delegate: SettingsViewControllerDelegate?
    var promptBackupWalletView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let promptBackupWalletView = promptBackupWalletView {
                promptBackupWalletView.translatesAutoresizingMaskIntoConstraints = false
                promptBackupWalletViewHolder.addSubview(promptBackupWalletView)
                NSLayoutConstraint.activate([
                    promptBackupWalletView.leadingAnchor.constraint(equalTo: promptBackupWalletViewHolder.leadingAnchor, constant: 7),
                    promptBackupWalletView.trailingAnchor.constraint(equalTo: promptBackupWalletViewHolder.trailingAnchor, constant: -7),
                    promptBackupWalletView.topAnchor.constraint(equalTo: promptBackupWalletViewHolder.topAnchor, constant: 7),
                    promptBackupWalletView.bottomAnchor.constraint(equalTo: promptBackupWalletViewHolder.bottomAnchor, constant: 0),
                ])
                tabBarItem.badgeValue = "1"
                showPromptBackupWalletViewAsTableHeaderView()
            } else {
                hidePromptBackupWalletView()
                tabBarItem.badgeValue = nil
            }
        }
    }

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.anchorsIgnoringBottomSafeArea(to: view)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorInset.left = 70
        if promptBackupWalletView == nil {
            hidePromptBackupWalletView()
        }

        view.backgroundColor = Configuration.Color.Semantic.defaultViewBackground

        bind(viewModel: viewModel)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        willAppear.send(())
    }

    private func bind(viewModel: SettingsViewModel) {
        let input = SettingsViewModelInput(
            willAppear: willAppear.eraseToAnyPublisher(),
            appProtectionSelection: appProtectionSelection.eraseToAnyPublisher(),
            blockscanChatUnreadCount: blockscanChatUnreadCount.eraseToAnyPublisher())

        let output = viewModel.transform(input: input)

        output.viewState
            .sink { [dataSource, tabBarItem, navigationItem] viewState in
                navigationItem.title = viewState.title
                dataSource.apply(viewState.snapshot, animatingDifferences: viewState.animatingDifferences)
                tabBarItem?.badgeValue = viewState.badge
            }.store(in: &cancellable)

        output.askToSetPasscode
            .sink { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.createPasswordSelected(in: strongSelf)
            }.store(in: &cancellable)
    }

    func configure(blockscanChatUnreadCount value: Int?) {
        blockscanChatUnreadCount.send(value)
    }

    private func showPromptBackupWalletViewAsTableHeaderView() {
        let size = promptBackupWalletViewHolder.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        promptBackupWalletViewHolder.bounds.size.height = size.height

        tableView.tableHeaderView = promptBackupWalletViewHolder
    }

    private func hidePromptBackupWalletView() {
        tableView.tableHeaderView = nil
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }
}

extension SettingsViewController: CanOpenURL {

    

    func didPressViewContractWebPage(forContract contract: AlphaWallet.Address, server: RPCServer, in viewController: UIViewController) {
        delegate?.didPressViewContractWebPage(forContract: contract, server: server, in: viewController)
    }

    func didPressViewContractWebPage(_ url: URL, in viewController: UIViewController) {
        delegate?.didPressViewContractWebPage(url, in: viewController)
    }

    func didPressOpenWebPage(_ url: URL, in viewController: UIViewController) {
        delegate?.didPressOpenWebPage(url, in: viewController)
    }
}

extension SettingsViewController: SwitchTableViewCellDelegate {

    func cell(_ cell: SwitchTableViewCell, switchStateChanged isOn: Bool) {
        guard let indexPath = cell.indexPath else { return }

        appProtectionSelection.send((indexPath, isOn))
    }
}
extension SettingsViewController: HideTokenSwitchTableViewCellDelegate {

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

extension SettingsViewController: ThemeSwitchTableViewCellDelegate {

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


fileprivate extension SettingsViewController {
    func makeDataSource() -> SettingsViewModel.DataSource {
        return SettingsViewModel.DataSource(tableView: tableView, cellProvider: { [weak self] tableView, indexPath, viewModel in
            guard let strongSelf = self else { return UITableViewCell() }

            switch viewModel {
            case .cell(let vm):
                let cell: SettingTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.configure(viewModel: vm)
                cell.accessoryView = vm.accessoryView
                cell.accessoryType = vm.accessoryType
                return cell
            case .undefined:
                return UITableViewCell()
            case .passcode(let vm):
                let cell: SwitchTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.configure(viewModel: vm)
                cell.delegate = self
               
                return cell
            case .hideToken(let vm):
                let cell: HideTokenSwitchTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.configure(viewModel: vm)
                cell.delegate = self
                return cell
            case .theme(let vm):
                let cell: ThemeSwitchTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.configure(viewModel: vm)
                cell.delegate = self
                return cell
            }
        })
    }
}

extension SettingsViewController: UITableViewDelegate {

    //Hide the footer
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        nil
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: SettingViewHeader = SettingViewHeader()
        let viewModel = SettingViewHeaderViewModel(section: self.viewModel.sections[section])
        headerView.configure(viewModel: viewModel)

        return headerView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch viewModel.sections[indexPath.section] {
        case .wallet(let rows):
            switch rows[indexPath.row] {
            case .backup:
                delegate?.backupWalletSelected(in: self)
            case .changeWallet:
                delegate?.changeWalletSelected(in: self)
            case .showMyWallet:
                delegate?.myWalletAddressSelected(in: self)
            case .showSeedPhrase:
                delegate?.showSeedPhraseSelected(in: self)
            case .walletConnect:
                delegate?.walletConnectSelected(in: self)
            case .nameWallet:
                delegate?.nameWalletSelected(in: self)
            case .mainWallet:
                delegate?.mainWalletSelected(in: self)
            }
        case .system(let rows):
            switch rows[indexPath.row] {
            case .advanced:
                delegate?.advancedSettingsSelected(in: self)
            case .notifications, .passcode, .hideToken, .theme:
                break
            case .selectActiveNetworks:
                delegate?.activeNetworksSelected(in: self)
            case .security:
                delegate?.securitySelected(in: self)
            case .blockscanChat:
                delegate?.blockscanChatSelected(in: self)
            }
        case .help(let rows):
            if let url = rows[indexPath.row].openUrl  {
                delegate?.didPressOpenWebPage(url, in: self)
            }
        case .tokenStandard:
            self.delegate?.didPressOpenWebPage(TokenScript.tokenScriptSite, in: self)
        case .version:
            break
        case .social(let rows):
            if let url = rows[indexPath.row].openUrl , UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: .none)
            } else {
                if let url = rows[indexPath.row].openUrl  {
                    delegate?.didPressOpenWebPage(url, in: self)
                }
            }
        case .activity(let rows):
            switch rows[indexPath.row] {
            case .activity:
                delegate?.activitySelected(in: self)
            case .scanQrCode:
                delegate?.scanQrSelected(in: self)
            case .walletConnect:
                delegate?.walletConnectSelected(in: self)
            case .contact:
                delegate?.addContactSelected(in: self)
        
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.heightForRow(at: indexPath, fallbackHeight: tableView.rowHeight)
    }
}
