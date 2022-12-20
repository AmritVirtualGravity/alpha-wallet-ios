// Copyright © 2022 Stormbird PTE. LTD.

import UIKit
import AlphaWalletFoundation

protocol SettingsWalletViewControllerDelegate: AnyObject {
    func changeWalletSelected(in controller: SettingsWalletViewController)
    func myWalletAddressSelected(in controller: SettingsWalletViewController)
    func backupWalletSelected(in controller: SettingsWalletViewController)
    func showSeedPhraseSelected(in controller: SettingsWalletViewController)
    func nameWalletSelected(in controller: SettingsWalletViewController)
    func exportJSONKeystoreSelected(in controller: SettingsWalletViewController)
}

class SettingsWalletViewController: UIViewController {
    private let viewModel: SettingsWalletViewModel
    private lazy var tableView: UITableView = {
        let tableView = UITableView.insetGroped
        tableView.register(SettingTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self

        return tableView
    }()
    
    weak var delegate: SettingsWalletViewControllerDelegate?

    init(viewModel: SettingsWalletViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.anchorsIgnoringBottomSafeArea(to: view)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configure(viewModel: viewModel)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    private func configure(viewModel: SettingsWalletViewModel) {
        title = viewModel.title
    }
}

extension SettingsWalletViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SettingTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(viewModel: viewModel.viewModel(for: indexPath))

        return cell
    }
}

extension SettingsWalletViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    //Hide the header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
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
        switch viewModel.row(for: indexPath) {
        case .backup:
            delegate?.backupWalletSelected(in: self)
        case .changeWallet:
            delegate?.changeWalletSelected(in: self)
        case .showMyWallet:
            delegate?.myWalletAddressSelected(in: self)
        case .showSeedPhrase:
            delegate?.showSeedPhraseSelected(in: self)
        case .nameWallet:
            delegate?.nameWalletSelected(in: self)
        case .exportJSONKeystore:
            delegate?.exportJSONKeystoreSelected(in: self)
        }
    }
}
