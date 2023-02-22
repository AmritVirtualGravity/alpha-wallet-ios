

import UIKit
import PromiseKit
import AlphaWalletFoundation
import AlphaWalletLogger



protocol AddContactCoordinatorCoordinatorDelegate: AnyObject {
    func didClose(in coordinator: ContactListCoordinator)
}

class AddContactCoordinator: Coordinator {
    var coordinators: [Coordinator] = []
    private let analytics: AnalyticsLogger
    private let wallet: Wallet
    private let domainResolutionService: DomainResolutionServiceType
    private let navigationController: UINavigationController
    weak var delegate: AddContactCoordinatorCoordinatorDelegate?
    private lazy var viewController: AddContactViewController = .init( domainResolutionService: domainResolutionService)

    init(analytics: AnalyticsLogger, wallet: Wallet, navigationController: UINavigationController,  domainResolutionService: DomainResolutionServiceType) {
        self.navigationController = navigationController
        self.domainResolutionService = domainResolutionService
        self.analytics = analytics
        self.wallet = wallet
    }

    func start(contact: ContactRmModel?, index: Int?) {
        viewController.delegate = self
        viewController.contactData = contact
        viewController.index = index
        if let contactData = contact {
            viewController.prepopulateContactData(contact: contactData)
            viewController.configure()
        }
        navigationController.pushViewController(viewController, animated: true)
    }

    @objc private func dismiss() {
        navigationController.popViewController(animated: true)
    }
}

extension AddContactCoordinator:AddContactViewControllerDelegate {
    
    
   
    
    func openQRCode(in controller: AddContactViewController) {
        guard let nc = controller.navigationController, nc.ensureHasDeviceAuthorization() else { return }

        let coordinator = ScanQRCodeCoordinator(analytics: analytics, navigationController: navigationController, account: wallet, domainResolutionService: domainResolutionService)
        coordinator.delegate = self
        addCoordinator(coordinator)

        coordinator.start(fromSource: .addCustomTokenScreen)
    }
    
    func didClose(viewController: AddContactViewController) {
//
    }
}

extension AddContactCoordinator: ScanQRCodeCoordinatorDelegate {

    func didCancel(in coordinator: ScanQRCodeCoordinator) {
        removeCoordinator(coordinator)
    }

    func didScan(result: String, in coordinator: ScanQRCodeCoordinator) {
        removeCoordinator(coordinator)
        viewController.didScanQRCode(result)
    }
}

