// Copyright SIX DAY LLC. All rights reserved.
// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import UIKit
import AlphaWalletFoundation



class SecurityCoordinator: Coordinator {
   
    private var config: Config
     private let analytics: AnalyticsLogger
    private let lock: Lock
      let navigationController: UINavigationController
    weak var delegate: LockCreatePasscodeCoordinatorDelegate?
    var coordinators: [Coordinator] = []

    lazy var rootViewController: SecurityViewController = {
        let viewModel = SecurityViewModel(config: config, lock: lock, analytics: analytics)
        let controller = SecurityViewController(viewModel: viewModel)
        controller.delegate = self
        controller.navigationItem.largeTitleDisplayMode = .always
        
        return controller
    }()

    init(
        navigationController: UINavigationController = .withOverridenBarAppearence(),
        config: Config,
        analytics: AnalyticsLogger,
        lock: Lock) {
            self.navigationController = navigationController
            self.lock = lock
            self.config = config
            self.analytics = analytics
        }
            
    

    func start() {
        navigationController.viewControllers = [rootViewController]
    }

}
extension SecurityCoordinator: SecurityViewControllerDelegate {
    func createPasswordSelected(in controller: SecurityViewController) {
        let coordinator = LockCreatePasscodeCoordinator(navigationController: navigationController, lock: lock)
        addCoordinator(coordinator)
        coordinator.delegate = self
        coordinator.start()
    }
}

extension SecurityCoordinator: LockCreatePasscodeCoordinatorDelegate {
    func didClose(in coordinator: LockCreatePasscodeCoordinator) {
        removeCoordinator(coordinator)
    }
}

