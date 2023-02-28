//
//  FungibleTokenCoordinator.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 19.11.2022.
//

import Foundation
import AlphaWalletFoundation
import PromiseKit
import Combine

protocol FungibleTokenCoordinatorDelegate: AnyObject, CanOpenURL {
    func didTapSwap(swapTokenFlow: SwapTokenFlow, in coordinator: FungibleTokenCoordinator)
    func didTapBridge(transactionType: TransactionType, service: TokenActionProvider, in coordinator: FungibleTokenCoordinator)
    func didTapBuy(transactionType: TransactionType, service: TokenActionProvider, in coordinator: FungibleTokenCoordinator)
    func didPress(for type: PaymentFlow, viewController: UIViewController, in coordinator: FungibleTokenCoordinator)
    func didTap(transaction: TransactionInstance, viewController: UIViewController, in coordinator: FungibleTokenCoordinator)
    func didTap(activity: Activity, viewController: UIViewController, in coordinator: FungibleTokenCoordinator)

    func didClose(in coordinator: FungibleTokenCoordinator)
}

class FungibleTokenCoordinator: Coordinator {
    private let keystore: Keystore
    private let assetDefinitionStore: AssetDefinitionStore
    private let analytics: AnalyticsLogger
    private let tokenActionsProvider: SupportedTokenActionsProvider
    private let coinTickersFetcher: CoinTickersFetcher
    private let activitiesService: ActivitiesServiceType
    private let sessions: ServerDictionary<WalletSession>
    private let session: WalletSession
    private let alertService: PriceAlertServiceType
    private let tokensService: TokenBalanceRefreshable & TokenViewModelState & TokenHolderState
    private let token: Token
    private let navigationController: UINavigationController
    private var cancelable = Set<AnyCancellable>()
    private let currencyService: CurrencyService
//    private lazy var rootViewController: FungibleTokenTabViewController = {
//        let viewModel = FungibleTokenTabViewModel(token: token, session: session, tokensService: tokensService, assetDefinitionStore: assetDefinitionStore)
//        let viewController = FungibleTokenTabViewController(viewModel: viewModel)
//        let viewControlers = viewModel.tabBarItems.map { buildViewController(tabBarItem: $0) }
//        viewController.set(viewControllers: viewControlers)
//        viewController.delegate = self
//
//        return viewController
//    }()
    
    private lazy var rootViewController: FungibleTokenDetailsViewController = {
        lazy var viewModel = FungibleTokenDetailsViewModel(token: self.token, coinTickersFetcher: self.coinTickersFetcher, tokensService: self.tokensService, session: self.session, assetDefinitionStore: self.assetDefinitionStore, tokenActionsProvider: self.tokenActionsProvider, currencyService: self.currencyService)
        let viewController = FungibleTokenDetailsViewController(viewModel: viewModel)
        viewController.delegate = self
        viewController.title = "\(token.name) (\(token.symbol))"
        return viewController
    }()

    var coordinators: [Coordinator] = []
    weak var delegate: FungibleTokenCoordinatorDelegate?

    init(token: Token,
         navigationController: UINavigationController,
         session: WalletSession,
         keystore: Keystore,
         assetDefinitionStore: AssetDefinitionStore,
         analytics: AnalyticsLogger,
         tokenActionsProvider: SupportedTokenActionsProvider,
         coinTickersFetcher: CoinTickersFetcher,
         activitiesService: ActivitiesServiceType,
         alertService: PriceAlertServiceType,
         tokensService: TokenBalanceRefreshable & TokenViewModelState & TokenHolderState,
         sessions: ServerDictionary<WalletSession>,
         currencyService: CurrencyService) {
        
        self.currencyService = currencyService
        self.token = token
        self.navigationController = navigationController
        self.sessions = sessions
        self.tokensService = tokensService
        self.session = session
        self.keystore = keystore
        self.assetDefinitionStore = assetDefinitionStore
        self.analytics = analytics
        self.tokenActionsProvider = tokenActionsProvider
        self.coinTickersFetcher = coinTickersFetcher
        self.activitiesService = activitiesService
        self.alertService = alertService
    }

    func start() {
        rootViewController.hidesBottomBarWhenPushed = true
        rootViewController.navigationItem.largeTitleDisplayMode = .never

        navigationController.pushViewController(rootViewController, animated: true)
    }
    
    private func buildViewController(tabBarItem: FungibleTokenTabViewModel.TabBarItem) -> UIViewController {
        switch tabBarItem {
        case .details:
            return buildDetailsViewController()
        case .activities:
            return buildActivitiesViewController()
        case .alerts:
            return buildAlertsViewController()
        }
    }

    private func buildActivitiesViewController() -> UIViewController {
        let viewController = ActivitiesViewController(analytics: analytics, keystore: keystore, wallet: session.account, viewModel: .init(collection: .init(activities: [])), sessions: sessions, assetDefinitionStore: assetDefinitionStore)
        viewController.delegate = self

        //FIXME: replace later with moving it to `ActivitiesViewController`
        activitiesService.activitiesPublisher
            .map { ActivityPageViewModel(activitiesViewModel: .init(collection: .init(activities: $0))) }
            .receive(on: RunLoop.main)
            .sink { [viewController] in
                viewController.configure(viewModel: $0.activitiesViewModel)
            }.store(in: &cancelable)
        
        activitiesService.start()

        return viewController
    }

    private func buildAlertsViewController() -> UIViewController {
        let viewModel = PriceAlertsViewModel(alertService: alertService, token: token)
        let viewController = PriceAlertsViewController(viewModel: viewModel)
        viewController.delegate = self

        return viewController
    }

    private func buildDetailsViewController() -> UIViewController {
        lazy var viewModel = FungibleTokenDetailsViewModel(token: token, coinTickersFetcher: coinTickersFetcher, tokensService: tokensService, session: session, assetDefinitionStore: assetDefinitionStore, tokenActionsProvider: tokenActionsProvider, currencyService: currencyService)
        let viewController = FungibleTokenDetailsViewController(viewModel: viewModel)
        viewController.delegate = self

        return viewController
    }
}

extension FungibleTokenCoordinator: FungibleTokenDetailsViewControllerDelegate {
    
    func didTapActivities(in viewController: FungibleTokenDetailsViewController) {
        guard let navigationController = viewController.navigationController else { return }
        let viewModel = ActivitiesViewModel(collection: .init())
        let controller = ActivitiesViewController(analytics: analytics, keystore: keystore, wallet: session.account, viewModel: viewModel, sessions: sessions, assetDefinitionStore: assetDefinitionStore)
        controller.hidesBottomBarWhenPushed = true
        controller.delegate = self
        activitiesService.activitiesPublisher
            .receive(on: RunLoop.main)
            .sink { [weak controller] activities in
                controller?.configure(viewModel: .init(collection: .init(activities: activities)))
            }.store(in: &cancelable)
        activitiesService.start()
        navigationController.pushViewController(controller, animated: true)
    }
    
    func didTapAlert(in viewController: FungibleTokenDetailsViewController) {
        guard let navigationController = viewController.navigationController else { return }
        let viewModel = PriceAlertsViewModel(alertService: alertService, token: token)
        let viewController = PriceAlertsViewController(viewModel: viewModel)
        viewController.edgesForExtendedLayout = []
        viewController.delegate = self
        navigationController.pushViewController(viewController, animated: true)
    }
    func didTapSwap(swapTokenFlow: SwapTokenFlow, in viewController: FungibleTokenDetailsViewController) {
        delegate?.didTapSwap(swapTokenFlow: swapTokenFlow, in: self)
    }

    func didTapBridge(for token: Token, service: TokenActionProvider, in viewController: FungibleTokenDetailsViewController) {
        delegate?.didTapBridge(transactionType: .init(fungibleToken: token), service: service, in: self)
    }

    func didTapBuy(for token: Token, service: TokenActionProvider, in viewController: FungibleTokenDetailsViewController) {
        delegate?.didTapBuy(transactionType: .init(fungibleToken: token), service: service, in: self)
    }

    func didTapSend(for token: Token, in viewController: FungibleTokenDetailsViewController) {
        delegate?.didPress(for: .send(type: .transaction(.init(fungibleToken: token))), viewController: viewController, in: self)
    }

    func didTapReceive(for token: Token, in viewController: FungibleTokenDetailsViewController) {
        delegate?.didPress(for: .request, viewController: viewController, in: self)
    }

    func didTap(action: TokenInstanceAction, token: Token, in viewController: FungibleTokenDetailsViewController) {
        guard let navigationController = viewController.navigationController else { return }

        let tokenHolder = token.getTokenHolder(assetDefinitionStore: assetDefinitionStore, forWallet: session.account)
        delegate?.didPress(for: .send(type: .tokenScript(action: action, token: token, tokenHolder: tokenHolder)), viewController: navigationController, in: self)
    }

    func didPressViewContractWebPage(forContract contract: AlphaWallet.Address, server: RPCServer, in viewController: UIViewController) {
        delegate?.didPressViewContractWebPage(forContract: contract, server: server, in: viewController)
    }

    func didPressViewContractWebPage(_ url: URL, in viewController: UIViewController) {
        delegate?.didPressOpenWebPage(url, in: viewController)
    }

    func didPressOpenWebPage(_ url: URL, in viewController: UIViewController) {
        delegate?.didPressOpenWebPage(url, in: viewController)
    }

}

extension FungibleTokenCoordinator: PriceAlertsViewControllerDelegate {
    func editAlertSelected(in viewController: PriceAlertsViewController, alert: PriceAlert) {
        let coordinator = EditPriceAlertCoordinator(navigationController: navigationController, configuration: .edit(alert), token: token, session: session, tokensService: tokensService, alertService: alertService, currencyService: currencyService)
        addCoordinator(coordinator)
        coordinator.delegate = self
        coordinator.start()
    }

    func addAlertSelected(in viewController: PriceAlertsViewController) {
        let coordinator = EditPriceAlertCoordinator(navigationController: navigationController, configuration: .create, token: token, session: session, tokensService: tokensService, alertService: alertService, currencyService: currencyService)
        addCoordinator(coordinator)
        coordinator.delegate = self
        coordinator.start()
    }
}

extension FungibleTokenCoordinator: ActivitiesViewControllerDelegate {
    func didPressActivity(activity: AlphaWalletFoundation.Activity, in viewController: ActivitiesViewController) {
        delegate?.didTap(activity: activity, viewController: viewController, in: self)
    }

    func didPressTransaction(transaction: AlphaWalletFoundation.TransactionInstance, in viewController: ActivitiesViewController) {
        delegate?.didTap(transaction: transaction, viewController: viewController, in: self)
    }
}

extension FungibleTokenCoordinator: EditPriceAlertCoordinatorDelegate {
    func didClose(in coordinator: EditPriceAlertCoordinator) {
        removeCoordinator(coordinator)
    }
}

extension FungibleTokenCoordinator: FungibleTokenTabViewControllerDelegate {
    func didClose(in viewController: FungibleTokenTabViewController) {
        delegate?.didClose(in: self)
    }

    func open(url: URL) {
        delegate?.didPressOpenWebPage(url, in: rootViewController)
    }
}