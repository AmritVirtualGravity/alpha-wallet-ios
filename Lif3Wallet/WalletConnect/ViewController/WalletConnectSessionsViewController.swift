// Copyright © 2020 Stormbird PTE. LTD.

import UIKit
import StatefulViewController
import AlphaWalletAddress
import Combine
import AlphaWalletFoundation

protocol WalletConnectSessionsViewControllerDelegate: AnyObject {
    func didDisconnectSelected(session: AlphaWallet.WalletConnect.Session, in viewController: WalletConnectSessionsViewController)
    func didSessionSelected(session: AlphaWallet.WalletConnect.Session, in viewController: WalletConnectSessionsViewController)
    func qrCodeSelected(in viewController: WalletConnectSessionsViewController)
    func didClose(in viewController: WalletConnectSessionsViewController)
}

class WalletConnectSessionsViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView.grouped
        tableView.register(WalletConnectSessionCell.self)
        tableView.estimatedRowHeight = DataEntry.Metric.TableView.estimatedRowHeight
        tableView.separatorInset = .zero
        tableView.delegate = self
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = R.image.lifeBackgroundImage()!
        return imageView
    }()

    private lazy var spinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true

        return view
    }()
    private var cancelable = Set<AnyCancellable>()
    private lazy var dataSource = WalletConnectSessionsViewModel.DataSource(tableView: tableView, cellProvider: { tableView, indexPath, session in
        let cell: WalletConnectSessionCell = tableView.dequeueReusableCell(for: indexPath)

        let viewModel = WalletConnectSessionCellViewModel(session: session)
        cell.configure(viewModel: viewModel)

        return cell
    })

    let viewModel: WalletConnectSessionsViewModel
    weak var delegate: WalletConnectSessionsViewControllerDelegate?

    init(viewModel: WalletConnectSessionsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

//        view.addSubview(backgroundImageView)
        view.addSubview(tableView)
        view.addSubview(spinner)

        NSLayoutConstraint.activate([
            // image view constraits for  full screen size
//            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
//            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
//            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
//            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            
            tableView.anchorsIgnoringBottomSafeArea(to: view),
            spinner.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])

        emptyView = EmptyView.walletSessionEmptyView(completion: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.qrCodeSelected(in: strongSelf)
        })
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let host = emptyView {
            spinner.bringSubviewToFront(host)
        }
        backgroundImageView.image = viewModel.backgroundImage
        bind(viewModel: viewModel)
    }

    private func bind(viewModel: WalletConnectSessionsViewModel) {
        let input = WalletConnectSessionsViewModelInput()
        let output = viewModel.transform(input: input)
        backgroundImageView.image = viewModel.backgroundImage
        output.viewState
            .sink { [weak self, spinner, navigationItem] viewState in
                navigationItem.title = viewState.title
                self?.dataSource.apply(viewState.snapshot, animatingDifferences: viewState.animatingDifferences)
                switch viewState.state {
                case .waitingForSessionConnection:
                    spinner.startAnimating()
                case .sessions:
                    spinner.stopAnimating()
                }

                self?.endLoading()
            }.store(in: &cancelable)
    }
}

extension WalletConnectSessionsViewController: StatefulViewController {
    func hasContent() -> Bool {
        return viewModel.hasAnyContent(dataSource)
    }
}

extension WalletConnectSessionsViewController: PopNotifiable {
    func didPopViewController(animated: Bool) {
        delegate?.didClose(in: self)
    }
}

extension WalletConnectSessionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let session = dataSource.itemIdentifier(for: indexPath) else { return }

        delegate?.didSessionSelected(session: session, in: self)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let title = R.string.localizable.walletConnectSessionDisconnect()
        let hideAction = UIContextualAction(style: .destructive, title: title) { [weak self] (_, _, completionHandler) in
            guard let strongSelf = self else { return }
            guard let session = strongSelf.dataSource.itemIdentifier(for: indexPath) else { return }

            strongSelf.delegate?.didDisconnectSelected(session: session, in: strongSelf)

            completionHandler(true)
        }

        hideAction.backgroundColor = R.color.danger()
        hideAction.image = R.image.hideToken()
        let configuration = UISwipeActionsConfiguration(actions: [hideAction])
        configuration.performsFirstActionWithFullSwipe = true

        return configuration
    }

    //Hide the header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
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
}