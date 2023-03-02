//
//  TransactionInProgressCoordinatorBridgeToPromise.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 16.11.2020.
//

import UIKit
import PromiseKit
import AlphaWalletFoundation

private class TransactionInProgressCoordinatorBridgeToPromise {

    private let (promiseToReturn, seal) = Promise<Void>.pending()
    private var retainCycle: TransactionInProgressCoordinatorBridgeToPromise?
    private let session: WalletSession

    init(navigationController: UINavigationController, coordinator: Coordinator, session: WalletSession) {
        self.session = session
        retainCycle = self
        
        let newCoordinator = TransactionInProgressCoordinator(presentingViewController: navigationController, session: session)
        newCoordinator.delegate = self
        coordinator.addCoordinator(newCoordinator)

        promiseToReturn.ensure {
            // ensure we break the retain cycle
            self.retainCycle = nil
            coordinator.removeCoordinator(newCoordinator)
        }.cauterize()

        newCoordinator.start()
    }

    var promise: Promise<Void> {
        return promiseToReturn
    }
}

extension TransactionInProgressCoordinatorBridgeToPromise: TransactionInProgressCoordinatorDelegate {

    func didDismiss(in coordinator: TransactionInProgressCoordinator) {
        seal.fulfill(())
    }
}

extension TransactionInProgressCoordinator {

    static func promise(_ navigationController: UINavigationController, coordinator: Coordinator, session: WalletSession) -> Promise<Void> {
        return TransactionInProgressCoordinatorBridgeToPromise(navigationController: navigationController, coordinator: coordinator, session: session).promise
    }
}
