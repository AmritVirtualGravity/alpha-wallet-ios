//
//  TransactionInProgressCoordinator.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 21.07.2020.
//

import UIKit
import AlphaWalletFoundation

protocol TransactionInProgressCoordinatorDelegate: AnyObject {
    func didDismiss(in coordinator: TransactionInProgressCoordinator)
}

class TransactionInProgressCoordinator: Coordinator, FloatingPanelControllerDelegate {
    private let session: WalletSession
    private lazy var viewControllerToPresent: FloatingPanelController = {
        let controller = TransactionInProgressViewController(viewModel: .init(server: session.server))
        controller.delegate = self
        
        let navigationController = NavigationController(rootViewController: controller)
        let panel = FloatingPanelController(isPanEnabled: false)
        panel.layout = CustomPanelLayout()
        panel.set(contentViewController: navigationController)
        panel.surfaceView.contentPadding = .init(top: 0, left: 0, bottom: 0, right: 0)
        panel.shouldDismissOnBackdrop = true
        panel.delegate = self

        return panel
    }()
    private let presentingViewController: UIViewController

    var coordinators: [Coordinator] = []
    weak var delegate: TransactionInProgressCoordinatorDelegate?

    init(presentingViewController: UIViewController, session: WalletSession) {
        self.presentingViewController = presentingViewController
        self.session = session
    }

    func start() {
        presentingViewController.present(viewControllerToPresent, animated: true)
    }
}

extension TransactionInProgressCoordinator: TransactionInProgressViewControllerDelegate {

    func didDismiss(in controller: TransactionInProgressViewController) {
        viewControllerToPresent.dismiss(animated: true) {
            self.delegate?.didDismiss(in: self)
        }
    }

    func controller(_ controller: TransactionInProgressViewController, okButtonSelected sender: UIButton) {
        viewControllerToPresent.dismiss(animated: true) {
            self.delegate?.didDismiss(in: self)
        }
    }
}
