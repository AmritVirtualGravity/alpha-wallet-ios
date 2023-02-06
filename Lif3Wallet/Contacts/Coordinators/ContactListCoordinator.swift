

import UIKit
import PromiseKit
import AlphaWalletFoundation
import AlphaWalletLogger



protocol ContactListCoordinatorDelegate: AnyObject {
    func didClose(in coordinator: ContactListCoordinator)
}

class ContactListCoordinator: Coordinator, ContactsListViewControllerDelegate, ContactListCoordinatorDelegate, AddContactCoordinatorCoordinatorDelegate {

    
    func didClose(in coordinator: ContactListCoordinator) {
        removeCoordinator(coordinator)
    }
    
    func didSelectAddContact(in viewController: ContactsListViewController) {
       let coordinator = AddContactCoordinator(analytics: analytics, wallet: wallet, navigationController: navigationController, domainResolutionService: domainResolutionService)
        addCoordinator(coordinator)
        coordinator.delegate = self
        coordinator.start()
    }
    
    var coordinators: [Coordinator] = []
    private let domainResolutionService: DomainResolutionServiceType
    private let navigationController: UINavigationController
    weak var delegate: ContactListCoordinatorDelegate?
    private let analytics: AnalyticsLogger
    private let wallet: Wallet
    init(analytics: AnalyticsLogger, wallet: Wallet, navigationController: UINavigationController,  domainResolutionService: DomainResolutionServiceType) {
        self.navigationController = navigationController
        self.domainResolutionService = domainResolutionService
        self.analytics = analytics
        self.wallet = wallet
    }

    func start() {
        let controller  = ContactsListViewController.instantiate()
        controller.hidesBottomBarWhenPushed = true
        controller.delegate = self
        navigationController.pushViewController(controller, animated: true)
    }

    @objc private func dismiss() {
        navigationController.popViewController(animated: true)
    }
}



