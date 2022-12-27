// Copyright SIX DAY LLC. All rights reserved.
// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import UIKit
import Combine
import AlphaWalletFoundation

enum RestartReason {
    case walletChange
    case changeLocalization
    case serverChange
    case currencyChange
}



protocol SettingsCoordinatorDelegate: class, CanOpenURL {
    func didRestart(with account: Wallet, in coordinator: SettingsCoordinator, reason: RestartReason)
    func didCancel(in coordinator: SettingsCoordinator)
    func didPressShowWallet(in coordinator: SettingsCoordinator)
    func showConsole(in coordinator: SettingsCoordinator)
    func restartToReloadServersQueued(in coordinator: SettingsCoordinator)
    func universalScannerSelected(in coordinator: SettingsCoordinator)
    func showWallets(in coordinator: SettingsCoordinator)
    
}

class SettingsCoordinator: Coordinator {
    private let activitiesPipeLine: ActivitiesPipeLine
    private let sessionsProvider: SessionsProvider
    private let assetDefinitionStore: AssetDefinitionStore
    private let transactionsDataStore: TransactionDataStore
    private let tokenCollection: TokenCollection
    private let appTracker: AppTracker
    private let activitiesService: ActivitiesServiceType
    private let nftProvider: NFTProvider
    private var tokenActionsService: TokenActionsService
    private var coinTickersFetcher: CoinTickersFetcher
    private var importToken: ImportToken
    private var tokensFilter: TokensFilter
    private let tokensService: DetectedContractsProvideble & TokenProvidable & TokenAddable
    private var pendingOperation: PendingOperation?
    private let tokenSwapper: TokenSwapper
    
    private let keystore: Keystore
    private var config: Config
    private let sessions: ServerDictionary<WalletSession>
    private let restartQueue: RestartTaskQueue
    private let promptBackupCoordinator: PromptBackupCoordinator
    private let analytics: AnalyticsLogger
    private let walletConnectCoordinator: WalletConnectCoordinator
    private let walletBalanceService: WalletBalanceService
    private let blockscanChatService: BlockscanChatService
    private let blockiesGenerator: BlockiesGenerator
    private let domainResolutionService: DomainResolutionServiceType
    private var account: Wallet {
        return sessions.anyValue.account
    }
    private let lock: Lock
    private let currencyService: CurrencyService
    private let tokenScriptOverridesFileManager: TokenScriptOverridesFileManager
    
    let navigationController: UINavigationController
    weak var delegate: SettingsCoordinatorDelegate?
    var coordinators: [Coordinator] = []
    
    private var tokensCoordinator: TokensCoordinator? {
        return coordinators.compactMap { $0 as? TokensCoordinator }.first
    }
    
    lazy var rootViewController: SettingsViewController = {
        let viewModel = SettingsViewModel(account: account, keystore: keystore, lock: lock, config: config, analytics: analytics, domainResolutionService: domainResolutionService)
        let controller = SettingsViewController(viewModel: viewModel)
        controller.delegate = self
        controller.navigationItem.largeTitleDisplayMode = .never
        
        return controller
    }()
    
    private var cancelable = Set<AnyCancellable>()
    
    private var transactionCoordinator: TransactionsCoordinator? {
        return coordinators.compactMap { $0 as? TransactionsCoordinator }.first
    }
    
    var dappBrowserCoordinator: DappBrowserCoordinator? {
        coordinators.compactMap { $0 as? DappBrowserCoordinator }.first
    }
    
   
    
 
    
    init(
        navigationController: UINavigationController = .withOverridenBarAppearence(),
        keystore: Keystore,
        config: Config,
        sessions: ServerDictionary<WalletSession>,
        restartQueue: RestartTaskQueue,
        promptBackupCoordinator: PromptBackupCoordinator,
        analytics: AnalyticsLogger,
        walletConnectCoordinator: WalletConnectCoordinator,
        walletBalanceService: WalletBalanceService,
        blockscanChatService: BlockscanChatService,
        blockiesGenerator: BlockiesGenerator,
        domainResolutionService: DomainResolutionServiceType,
        lock: Lock,
        currencyService: CurrencyService,
        tokenScriptOverridesFileManager: TokenScriptOverridesFileManager,
        
        
        
        activitiesPipeLine: ActivitiesPipeLine,
        sessionsProvider: SessionsProvider,
        assetDefinitionStore: AssetDefinitionStore,
        transactionsDataStore: TransactionDataStore,
        tokenCollection: TokenCollection,
        appTracker: AppTracker,
        activitiesService: ActivitiesServiceType,
        nftProvider: NFTProvider,
        tokenActionsService: TokenActionsService,
        coinTickersFetcher: CoinTickersFetcher,
        importToken: ImportToken,
        tokensFilter: TokensFilter,
        tokensService: DetectedContractsProvideble & TokenProvidable & TokenAddable,
        tokenSwapper: TokenSwapper
        
    ) {
        self.tokenScriptOverridesFileManager = tokenScriptOverridesFileManager
        self.navigationController = navigationController
        self.lock = lock
        self.keystore = keystore
        self.config = config
        self.sessions = sessions
        self.restartQueue = restartQueue
        self.promptBackupCoordinator = promptBackupCoordinator
        self.analytics = analytics
        self.walletConnectCoordinator = walletConnectCoordinator
        self.walletBalanceService = walletBalanceService
        self.blockscanChatService = blockscanChatService
        self.blockiesGenerator = blockiesGenerator
        self.domainResolutionService = domainResolutionService
        self.currencyService = currencyService
        
        
        self.activitiesPipeLine = activitiesPipeLine
        self.sessionsProvider = sessionsProvider
        self.assetDefinitionStore = assetDefinitionStore
        self.transactionsDataStore = transactionsDataStore
        self.tokenCollection = tokenCollection
        self.appTracker = appTracker
        self.activitiesService = activitiesService
        self.nftProvider = nftProvider
        self.tokenActionsService = tokenActionsService
        self.coinTickersFetcher = coinTickersFetcher
        self.importToken = importToken
        self.tokensFilter = tokensFilter
        self.tokensService = tokensService
        self.tokenSwapper = tokenSwapper
        promptBackupCoordinator.subtlePromptDelegate = self
    }
    
    func start() {
        let tokenCoordinator = createTokensCoordinator(promptBackupCoordinator: promptBackupCoordinator, activitiesService: activitiesService)
        let txnCoordinator =  createTransactionCoordinator(transactionDataStore: transactionsDataStore)
        navigationController.viewControllers = [rootViewController]
    }
    
    func restart(for wallet: Wallet, reason: RestartReason) {
        delegate?.didRestart(with: wallet, in: self, reason: reason)
    }
    
    func showBlockscanChatUnreadCount(_ count: Int?) {
        rootViewController.configure(blockscanChatUnreadCount: count)
    }
    
    private func createTokensCoordinator(promptBackupCoordinator: PromptBackupCoordinator, activitiesService: ActivitiesServiceType) -> TokensCoordinator {
        promptBackupCoordinator.listenToNativeCryptoCurrencyBalance(service: tokenCollection)

        let coordinator = TokensCoordinator(
                sessions: sessionsProvider.activeSessions,
                keystore: keystore,
                config: config,
                assetDefinitionStore: assetDefinitionStore,
                promptBackupCoordinator: promptBackupCoordinator,
                analytics: analytics,
                nftProvider: nftProvider,
                tokenActionsService: tokenActionsService,
                walletConnectCoordinator: walletConnectCoordinator,
                coinTickersFetcher: coinTickersFetcher,
                activitiesService: activitiesService,
                walletBalanceService: walletBalanceService,
                tokenCollection: tokenCollection,
                importToken: importToken,
                blockiesGenerator: blockiesGenerator,
                domainResolutionService: domainResolutionService,
                tokensFilter: tokensFilter
        )
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
        return coordinator
    }
    
    
    private func createTransactionCoordinator(transactionDataStore: TransactionDataStore) -> TransactionsCoordinator {
        let transactionsService = TransactionsService(
            sessions: sessionsProvider.activeSessions,
            transactionDataStore: transactionDataStore,
            analytics: analytics,
            tokensService: tokensService)

        transactionsService.delegate = self
        transactionsService.start()

        let coordinator = TransactionsCoordinator(
            analytics: analytics,
            sessions: sessionsProvider.activeSessions,
            transactionsService: transactionsService,
            tokensService: tokenCollection)

        coordinator.rootViewController.tabBarItem = ActiveWalletViewModel.Tabs.transactions.tabBarItem
        coordinator.navigationController.configureForLargeTitles()
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)

        return coordinator
    }
}


extension SettingsCoordinator: WhereAreMyTokensCoordinatorDelegate {

    func switchToMainnetSelected(in coordinator: WhereAreMyTokensCoordinator) {
        restartQueue.add(.reloadServers(Constants.defaultEnabledServers))
        processRestartQueueAndRestartUI(reason: .serverChange)
    }

    func didClose(in coordinator: WhereAreMyTokensCoordinator) {
        //no-op
    }
    
    func processRestartQueueAndRestartUI(reason: RestartReason) {
        RestartQueueHandler(config: config).processRestartQueueBeforeRestart(restartQueue: restartQueue)
        restartUI(withReason: reason, account: account)
    }
        
        private func restartUI(withReason reason: RestartReason, account: Wallet) {
            delegate?.didRestart(with: account, in: self, reason: reason)
        }
    
}

extension SettingsCoordinator: PaymentCoordinatorDelegate {
    func didSelectTokenHolder(tokenHolder: TokenHolder, in coordinator: PaymentCoordinator) {
        guard let coordinator = coordinatorOfType(type: NFTCollectionCoordinator.self) else { return }

        coordinator.showNftAsset(tokenHolder: tokenHolder, mode: .preview)
    }

    func didSendTransaction(_ transaction: SentTransaction, inCoordinator coordinator: PaymentCoordinator) {
        handlePendingTransaction(transaction: transaction)
    }

    func didFinish(_ result: ConfirmResult, in coordinator: PaymentCoordinator) {
        coordinator.dismiss(animated: true)
        removeCoordinator(coordinator)
        askUserToRateAppOrSubscribeToNewsletter()
    }

    //NOTE: askUserToRateAppOrSubscribeToNewsletter can't be called ringht in confirmation coordinator as after successfully sent transaction coordinator dismissed
    private func askUserToRateAppOrSubscribeToNewsletter() {
        let hostViewController = UIApplication.shared.presentedViewController(or: navigationController)
        let coordinator = HelpUsCoordinator(hostViewController: hostViewController, appTracker: appTracker, analytics: analytics)
        coordinator.rateUsOrSubscribeToNewsletter()
    }

    func didCancel(in coordinator: PaymentCoordinator) {
        coordinator.dismiss(animated: true)

        removeCoordinator(coordinator)
    }
}



extension SettingsCoordinator: SelectTokenCoordinatorDelegate {
    
    func showPaymentFlow(for type: PaymentFlow, server: RPCServer, navigationController: UINavigationController) {
        switch (type, account.type) {
        case (.send, .real), (.swap, .real), (.request, _),
            (_, _) where Config().development.shouldPretendIsRealWallet:
            let coordinator = PaymentCoordinator(
                    navigationController: navigationController,
                    flow: type,
                    server: server,
                    sessionProvider: sessionsProvider,
                    keystore: keystore,
                    assetDefinitionStore: assetDefinitionStore,
                    analytics: analytics,
                    tokenCollection: tokenCollection,
                    domainResolutionService: domainResolutionService,
                    tokenSwapper: tokenSwapper,
                    tokensFilter: tokensFilter,
                    importToken: importToken)
            coordinator.delegate = self
            coordinator.start()

            addCoordinator(coordinator)
        case (_, _):
            if let topVC = navigationController.presentedViewController {
                topVC.displayError(error: ActiveWalletViewModel.Error.onlyWatchAccount)
            } else {
                navigationController.displayError(error: ActiveWalletViewModel.Error.onlyWatchAccount)
            }
        }
    }
    
    func coordinator(_ coordinator: SelectTokenCoordinator, didSelectToken token: Token) {
        removeCoordinator(coordinator)

        do {
            guard let operation = pendingOperation else { throw ActiveWalletError.operationForTokenNotFound }

            switch operation {
            case .swapToken:
                try swapToken(token: token)
            case .sendToken(let recipient):
                let paymentFlow = PaymentFlow.send(type: .transaction(.init(fungibleToken: token, recipient: recipient, amount: nil)))
                showPaymentFlow(for: paymentFlow, server: token.server, navigationController: navigationController)
            }
        } catch {
            show(error: error)
        }
    }

    func didCancel(in coordinator: SelectTokenCoordinator) {
        removeCoordinator(coordinator)
    }
}

extension SettingsCoordinator: SelectServiceToSwapCoordinatorDelegate {
    func selectSwapService(_ result: Swift.Result<SwapTokenUsing, SwapTokenError>, in coordinator: SelectServiceToSwapCoordinator) {
        removeCoordinator(coordinator)

        switch result {
        case .success(let swapTokenUsing):
            switch swapTokenUsing {
            case .url(let url, let server):
                if let server = server {
                    open(url: url, onServer: server)
                } else {
                    open(for: url)
                }
            case .native(let swapPair):
                showPaymentFlow(for: .swap(pair: swapPair), server: swapPair.from.server, navigationController: navigationController)
            }
        case .failure(let error):
            show(error: error)
        }
    }

    func didClose(in coordinator: SelectServiceToSwapCoordinator) {
        removeCoordinator(coordinator)
    }
}


extension SettingsCoordinator: TokensCoordinatorDelegate {
    
    func show(error: Error) {
        //TODO Not comprehensive. Example, if we are showing a token instance view and tap on unverified to open browser, this wouldn't owrk
        if let topVC = navigationController.presentedViewController {
            topVC.displayError(error: error)
        } else {
            navigationController.displayError(error: error)
        }
    }
    
    func didSendTransaction(_ transaction: SentTransaction, inCoordinator coordinator: TransactionConfirmationCoordinator) {
        //
    }
    

    func viewWillAppearOnce(in coordinator: TokensCoordinator) {
        tokenCollection.refreshBalance(updatePolicy: .all)
        activitiesPipeLine.start()
    }

    func whereAreMyTokensSelected(in coordinator: TokensCoordinator) {
        let coordinator = WhereAreMyTokensCoordinator(navigationController: navigationController)
        coordinator.delegate = self
        addCoordinator(coordinator)

        coordinator.start()
    }

    func blockieSelected(in coordinator: TokensCoordinator) {
        delegate?.showWallets(in: self)
    }


    func didTap(activity: Activity, viewController: UIViewController, in coordinator: TokensCoordinator) {
        guard let navigationController = viewController.navigationController else { return }

        showActivity(activity, navigationController: navigationController)
    }

    func didTapSwap(swapTokenFlow: SwapTokenFlow, in coordinator: TokensCoordinator) {
        do {
            switch swapTokenFlow {
            case .swapToken(let token):
                try swapToken(token: token)
            case .selectTokenToSwap:
                showTokenSelection(for: .swapToken)
            }
        } catch {
            show(error: error)
        }
    }

    private func showTokenSelection(for operation: PendingOperation) {
        self.pendingOperation = operation

        let coordinator = SelectTokenCoordinator(tokenCollection: tokenCollection, tokensFilter: tokensFilter, navigationController: navigationController, filter: .filter(NativeCryptoOrErc20TokenFilter()))
        coordinator.delegate = self
        addCoordinator(coordinator)

        coordinator.start()
    }

    private func swapToken(token: Token) throws {
        guard let swapTokenProvider = tokenActionsService.service(ofType: SwapTokenProvider.self) as? SwapTokenProvider else {
            throw ActiveWalletError.unavailableToResolveSwapActionProvider
        }

        let coordinator = SelectServiceToSwapCoordinator(swapTokenProvider: swapTokenProvider, token: token, analytics: analytics, viewController: navigationController)
        coordinator.delegate = self
        coordinator.start(wallet: account)
        addCoordinator(coordinator)
    }

    func didTapBridge(transactionType: TransactionType, service: TokenActionProvider, in coordinator: TokensCoordinator) {
        do {
            guard let service = service as? BridgeTokenURLProviderType else {
                throw ActiveWalletError.unavailableToResolveBridgeActionProvider
            }
            guard let token = transactionType.swapServiceInputToken, let url = service.url(token: token, wallet: account) else {
                throw ActiveWalletError.bridgeNotSupported
            }

            open(url: url, onServer: token.server)
        } catch {
            show(error: error)
        }
    }
    
    private func buyCrypto(wallet: Wallet, token: TokenActionsIdentifiable, viewController: UIViewController, source: Analytics.BuyCryptoSource) {
        guard let buyTokenProvider = tokenActionsService.service(ofType: BuyTokenProvider.self) as? BuyTokenProvider else { return }
        let coordinator = SelectServiceToBuyCryptoCoordinator(buyTokenProvider: buyTokenProvider, token: token, viewController: viewController, source: source, analytics: analytics)
        coordinator.delegate = self
        coordinator.start(wallet: wallet)
        addCoordinator(coordinator)
    }

    func didTapBuy(transactionType: TransactionType, service: TokenActionProvider, in coordinator: TokensCoordinator) {
        do {
            guard let token = transactionType.swapServiceInputToken else { throw ActiveWalletError.buyNotSupported }
            buyCrypto(wallet: account, token: token, viewController: navigationController, source: .token)
        } catch {
            show(error: error)
        }
    }

    private func open(for url: URL) {
        guard let dappBrowserCoordinator = dappBrowserCoordinator else { return }
        showTab(.browser)
        dappBrowserCoordinator.open(url: url, animated: true)
    }

    private func open(url: URL, onServer server: RPCServer) {
        //Server shouldn't be disabled since the action is selected
        guard let dappBrowserCoordinator = dappBrowserCoordinator, config.enabledServers.contains(server) else { return }
        showTab(.browser)
        dappBrowserCoordinator.switch(toServer: server, url: url)
    }
    
    func showTab(_ selectTab: ActiveWalletViewModel.Tabs) {
//        guard let viewControllers = tabBarController.viewControllers else {
//            return
//        }
//
//        for controller in viewControllers {
//            if let nav = controller as? UINavigationController, nav.viewControllers[0].className == selectTab.className {
//                tabBarController.selectedViewController = nav
//                loadHomePageIfEmpty()
//            }
//        }
    }
    
    private func loadHomePageIfEmpty() {
        guard let coordinator = dappBrowserCoordinator, !coordinator.hasWebPageLoaded else { return }

        if let url = config.homePageURL {
            coordinator.open(url: url, animated: false)
        } else {
            coordinator.showDappsHome()
        }
    }
    
    func didTap(suggestedPaymentFlow: SuggestedPaymentFlow, viewController: UIViewController?, in coordinator: TokensCoordinator) {
        let navigationController: UINavigationController
        if let nvc = viewController?.navigationController {
            navigationController = nvc
        } else {
            navigationController = coordinator.navigationController
        }

        switch suggestedPaymentFlow {
        case .payment(let type, let server):
            showPaymentFlow(for: type, server: server, navigationController: navigationController)
        case .other(let action):
            switch action {
            case .sendToRecipient(let recipient):
                showTokenSelection(for: .sendToken(recipient: recipient))
            }
        }
    }

    func didTap(transaction: TransactionInstance, viewController: UIViewController, in coordinator: TokensCoordinator) {
        if transaction.localizedOperations.count > 1 {
            transactionCoordinator?.showTransaction(.group(transaction), inViewController: viewController)
        } else {
            transactionCoordinator?.showTransaction(.standalone(transaction), inViewController: viewController)
        }
    }

    func openConsole(inCoordinator coordinator: TokensCoordinator) {
        showConsole(navigationController: coordinator.navigationController)
    }
    
    private func showConsole(navigationController: UINavigationController) {
        let coordinator = ConsoleCoordinator(assetDefinitionStore: assetDefinitionStore, navigationController: navigationController)
        coordinator.delegate = self
        addCoordinator(coordinator)
        coordinator.start()
    }

    func didPostTokenScriptTransaction(_ transaction: SentTransaction, in coordinator: TokensCoordinator) {
        handlePendingTransaction(transaction: transaction)
    }

    func didSentTransaction(transaction: SentTransaction, in coordinator: TokensCoordinator) {
        handlePendingTransaction(transaction: transaction)
    }

    func didSelectAccount(account: Wallet, in coordinator: TokensCoordinator) {
        guard self.account != account else { return }
        restartUI(withReason: .walletChange, account: account)
    }
}

extension SettingsCoordinator: ConsoleCoordinatorDelegate {
    func didCancel(in coordinator: ConsoleCoordinator) {
        removeCoordinator(coordinator)
    }
}

extension SettingsCoordinator: SelectServiceToBuyCryptoCoordinatorDelegate {
    func selectBuyService(_ result: Swift.Result<Void, BuyCryptoError>, in coordinator: SelectServiceToBuyCryptoCoordinator) {
        removeCoordinator(coordinator)

        switch result {
        case .success: break
        case .failure(let error): show(error: error)
        }
    }

    func didClose(in coordinator: SelectServiceToBuyCryptoCoordinator) {
        removeCoordinator(coordinator)
    }

    func buyCrypto(wallet: Wallet, server: RPCServer, viewController: UIViewController, source: Analytics.BuyCryptoSource) {
        let token = MultipleChainsTokensDataStore.functional.etherToken(forServer: server)
        buyCrypto(wallet: wallet, token: token, viewController: viewController, source: source)
    }

}

extension SettingsCoordinator: RenameWalletViewControllerDelegate {
    
    func didFinish(in viewController: RenameWalletViewController) {
        navigationController.popViewController(animated: true)
    }
}

extension SettingsCoordinator: LockCreatePasscodeCoordinatorDelegate {
    func didClose(in coordinator: LockCreatePasscodeCoordinator) {
        removeCoordinator(coordinator)
    }
}



extension SettingsCoordinator: ReplaceTransactionCoordinatorDelegate {
   
    
    func didSendTransaction(_ transaction: SentTransaction, inCoordinator coordinator: ReplaceTransactionCoordinator) {
        handlePendingTransaction(transaction: transaction)
    }
    
    func didFinish(_ result: ConfirmResult, in coordinator: ReplaceTransactionCoordinator) {
        removeCoordinator(coordinator)
        askUserToRateAppOrSubscribeToNewsletter()
    }
    
    
    
    private func handlePendingTransaction(transaction: SentTransaction) {
        transactionCoordinator?.addSentTransaction(transaction)
    }
    
   
    
}


extension SettingsCoordinator: ActivityViewControllerDelegate {
    func reinject(viewController: ActivityViewController) {
        activitiesPipeLine.reinject(activity: viewController.viewModel.activity)
    }
    
    func goToToken(viewController: ActivityViewController) {
        let token = viewController.viewModel.activity.token
        guard let tokensCoordinator = tokensCoordinator, let navigationController = viewController.navigationController else { return }

        tokensCoordinator.showSingleChainToken(token: token, in: navigationController)
    }
    
    func speedupTransaction(transactionId: String, server: RPCServer, viewController: ActivityViewController) {
        guard let transaction = transactionsDataStore.transaction(withTransactionId: transactionId, forServer: server) else { return }
        guard let session = sessionsProvider.session(for: transaction.server) else { return }
        guard let coordinator = ReplaceTransactionCoordinator(analytics: analytics, domainResolutionService: domainResolutionService, keystore: keystore, presentingViewController: viewController, session: session, transaction: transaction, mode: .speedup, assetDefinitionStore: assetDefinitionStore, tokensService: tokenCollection) else { return }
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
    }
    
    func cancelTransaction(transactionId: String, server: RPCServer, viewController: ActivityViewController) {
        guard let transaction = transactionsDataStore.transaction(withTransactionId: transactionId, forServer: server) else { return }
        guard let session = sessionsProvider.session(for: transaction.server) else { return }
        guard let coordinator = ReplaceTransactionCoordinator(analytics: analytics, domainResolutionService: domainResolutionService, keystore: keystore, presentingViewController: viewController, session: session, transaction: transaction, mode: .cancel, assetDefinitionStore: assetDefinitionStore, tokensService: tokenCollection) else { return }
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
    }
    
    func goToTransaction(viewController: ActivityViewController) {
        transactionCoordinator?.showTransaction(withId: viewController.viewModel.activity.transactionId, server: viewController.viewModel.activity.server, inViewController: viewController)
    }
    
    func didPressViewContractWebPage(_ contract: AlphaWallet.Address, server: RPCServer, viewController: ActivityViewController) {
        didPressViewContractWebPage(forContract: contract, server: server, in: viewController)
    }
}

extension SettingsCoordinator: TransactionsServiceDelegate {
    
    func didCompleteTransaction(in service: TransactionsService, transaction: TransactionInstance) {
        tokenCollection.refreshBalance(updatePolicy: .all)
    }
    
    func didExtractNewContracts(in service: TransactionsService, contractsAndServers: [AddressAndRPCServer]) {
        for each in contractsAndServers {
            assetDefinitionStore.fetchXML(forContract: each.address, server: each.server)
        }
    }
}




extension SettingsCoordinator: ActivitiesViewControllerDelegate {
    
    func didPressActivity(activity: Activity, in viewController: ActivitiesViewController) {
        guard let navigationController = viewController.navigationController else { return }
        
        showActivity(activity, navigationController: navigationController)
    }
    
    func didPressTransaction(transaction: TransactionInstance, in viewController: ActivitiesViewController) {
        let transactionsService = TransactionsService(
            sessions: sessionsProvider.activeSessions,
            transactionDataStore: transactionsDataStore,
            analytics: analytics,
            tokensService: tokensService)
        
        transactionsService.delegate = self
        transactionsService.start()
        let coordinator = TransactionsCoordinator(
            analytics: analytics,
            sessions: sessionsProvider.activeSessions,
            transactionsService: transactionsService,
            tokensService: tokenCollection)
        if transaction.localizedOperations.count > 1 {
            coordinator.showTransaction(.group(transaction), inViewController: viewController)
        } else {
            coordinator.showTransaction(.standalone(transaction), inViewController: viewController)
        }
    }
    
    
    private func showActivity(_ activity: Activity, navigationController: UINavigationController) {
        let controller = ActivityViewController(analytics: analytics, wallet: account, assetDefinitionStore: assetDefinitionStore, viewModel: .init(activity: activity), service: activitiesPipeLine, keystore: keystore)
        controller.delegate = self
        controller.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(controller, animated: true)
    }
}



extension SettingsCoordinator: SettingsViewControllerDelegate {
    
    func activitySelected(in controller: SettingsViewController) {
        let viewModel = ActivitiesViewModel(collection: .init())
        let controller = ActivitiesViewController(analytics: analytics, keystore: keystore, wallet: account, viewModel: viewModel, sessions: sessions, assetDefinitionStore: assetDefinitionStore)
        controller.hidesBottomBarWhenPushed = true
        controller.delegate = self
        activitiesService.activitiesPublisher
            .receive(on: RunLoop.main)
            .sink { [weak controller] activities in
                controller?.configure(viewModel: .init(collection: .init(activities: activities)))
            }.store(in: &cancelable)
        self.navigationController.pushViewController(controller, animated: true)
        
    }
    
    func scanQrSelected(in controller: SettingsViewController) {
        delegate?.universalScannerSelected(in: self)
    }
    
    
    func mainWalletSelected(in controller: SettingsViewController) {
        let viewModel = SettingsWalletViewModel(config: config)
        let viewController = SettingsWalletViewController(viewModel: viewModel)
        viewController.delegate = self
        viewController.hidesBottomBarWhenPushed = true
        viewController.navigationItem.largeTitleDisplayMode = .never
        navigationController.pushViewController(viewController, animated: true)
    }
    
    
    func securitySelected(in controller: SettingsViewController) {
        let viewModel = SecurityViewModel(config: config, lock: lock, analytics: analytics)
        let viewController = SecurityViewController(viewModel: viewModel)
        viewController.delegate = self
        viewController.hidesBottomBarWhenPushed = true
        viewController.navigationItem.largeTitleDisplayMode = .never
        navigationController.pushViewController(viewController, animated: true)
    }
    
    
    func createPasswordSelected(in controller: SettingsViewController) {
        let coordinator = LockCreatePasscodeCoordinator(navigationController: navigationController, lock: lock)
        addCoordinator(coordinator)
        coordinator.delegate = self
        coordinator.start()
    }
    
    func nameWalletSelected(in controller: SettingsViewController) {
        let viewModel = RenameWalletViewModel(account: account.address, analytics: analytics, domainResolutionService: domainResolutionService)
        let viewController = RenameWalletViewController(viewModel: viewModel)
        viewController.delegate = self
        viewController.navigationItem.largeTitleDisplayMode = .never
        viewController.hidesBottomBarWhenPushed = true
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func blockscanChatSelected(in controller: SettingsViewController) {
        blockscanChatService.openBlockscanChat(forAddress: account.address)
    }
    
    func walletConnectSelected(in controller: SettingsViewController) {
        walletConnectCoordinator.showSessions()
    }
    
    func showSeedPhraseSelected(in controller: SettingsViewController) {
        guard case .real(let account) = account.type else { return }
        
        let coordinator = ShowSeedPhraseCoordinator(navigationController: navigationController, keystore: keystore, account: account)
        addCoordinator(coordinator)
        coordinator.delegate = self
        coordinator.start()
    }
    
    func helpSelected(in controller: SettingsViewController) {
        let coordinator = SupportCoordinator(navigationController: navigationController, analytics: analytics)
        coordinator.delegate = self
        addCoordinator(coordinator)
        
        coordinator.start()
    }
    
    func changeWalletSelected(in controller: SettingsViewController) {
        let coordinator = AccountsCoordinator(
            config: config,
            navigationController: navigationController,
            keystore: keystore,
            analytics: analytics,
            viewModel: .init(configuration: .changeWallets, animatedPresentation: true),
            walletBalanceService: walletBalanceService,
            blockiesGenerator: blockiesGenerator,
            domainResolutionService: domainResolutionService)
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
    }
    
    func myWalletAddressSelected(in controller: SettingsViewController) {
        delegate?.didPressShowWallet(in: self)
    }
    
    func backupWalletSelected(in controller: SettingsViewController) {
        guard case .real = account.type else { return }
        
        let coordinator = BackupCoordinator(navigationController: navigationController, keystore: keystore, account: account, analytics: analytics)
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
    }
    
    func activeNetworksSelected(in controller: SettingsViewController) {
        let coordinator = EnabledServersCoordinator(navigationController: navigationController, selectedServers: config.enabledServers, restartQueue: restartQueue, analytics: analytics, config: config)
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
    }
    
    func advancedSettingsSelected(in controller: SettingsViewController) {
        let viewModel = AdvancedSettingsViewModel(wallet: account, config: config)
        let controller = AdvancedSettingsViewController(viewModel: viewModel)
        controller.delegate = self
        controller.hidesBottomBarWhenPushed = true
        controller.navigationItem.largeTitleDisplayMode = .never
        
        navigationController.pushViewController(controller, animated: true)
    }
}

extension SettingsCoordinator: ShowSeedPhraseCoordinatorDelegate {
    func didCancel(in coordinator: ShowSeedPhraseCoordinator) {
        removeCoordinator(coordinator)
    }
}

extension SettingsCoordinator: SecurityViewControllerDelegate {
    func createPasswordSelected(in controller: SecurityViewController) {
        let coordinator = LockCreatePasscodeCoordinator(navigationController: navigationController, lock: lock)
        addCoordinator(coordinator)
        coordinator.delegate = self
        coordinator.start()
    }
}

extension SettingsCoordinator: SupportCoordinatorDelegate {
    func didClose(in coordinator: SupportCoordinator) {
        removeCoordinator(coordinator)
    }
}

extension SettingsCoordinator: TransactionsCoordinatorDelegate {
    
    
    
}


extension SettingsCoordinator: CanOpenURL {
    
    
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

extension SettingsCoordinator: AccountsCoordinatorDelegate {
    
    func didFinishBackup(account: AlphaWallet.Address, in coordinator: AccountsCoordinator) {
        promptBackupCoordinator.markBackupDone()
        promptBackupCoordinator.showHideCurrentPrompt()
    }
    
    func didAddAccount(account: Wallet, in coordinator: AccountsCoordinator) {
        //no-op
    }
    
    func didDeleteAccount(account: Wallet, in coordinator: AccountsCoordinator) {
        guard !coordinator.accountsViewController.viewModel.hasWallets else { return }
        coordinator.navigationController.popViewController(animated: true)
        delegate?.didCancel(in: self)
    }
    
    func didCancel(in coordinator: AccountsCoordinator) {
        //        coordinator.navigationController.popViewController(animated: true)
        removeCoordinator(coordinator)
    }
    
    func didSelectAccount(account: Wallet, in coordinator: AccountsCoordinator) {
        coordinator.navigationController.popViewController(animated: true)
        removeCoordinator(coordinator)
        if self.account == account {
            //no-op
        } else {
            restart(for: account, reason: .walletChange)
        }
    }
}

extension SettingsCoordinator: LocalesCoordinatorDelegate {
    func didSelect(locale: AppLocale, in coordinator: LocalesCoordinator) {
        coordinator.localesViewController.navigationController?.popViewController(animated: true)
        removeCoordinator(coordinator)
        restart(for: account, reason: .changeLocalization)
    }
}

extension SettingsCoordinator: EnabledServersCoordinatorDelegate {
    
    func restartToReloadServersQueued(in coordinator: EnabledServersCoordinator) {
        delegate?.restartToReloadServersQueued(in: self)
        removeCoordinator(coordinator)
    }
    
}

extension SettingsCoordinator: PromptBackupCoordinatorSubtlePromptDelegate {
    var viewControllerToShowBackupLaterAlert: UIViewController {
        return rootViewController
    }
    
    func updatePrompt(inCoordinator coordinator: PromptBackupCoordinator) {
        rootViewController.promptBackupWalletView = coordinator.subtlePromptView
    }
}

extension SettingsCoordinator: BackupCoordinatorDelegate {
    func didCancel(coordinator: BackupCoordinator) {
        removeCoordinator(coordinator)
    }
    
    func didFinish(account: AlphaWallet.Address, in coordinator: BackupCoordinator) {
        promptBackupCoordinator.markBackupDone()
        promptBackupCoordinator.showHideCurrentPrompt()
        removeCoordinator(coordinator)
    }
}

extension SettingsCoordinator: AdvancedSettingsViewControllerDelegate {
    func moreSelected(in controller: AdvancedSettingsViewController) {
        let viewModel = ToolsViewModel(config: config)
        let viewController = ToolsViewController(viewModel: viewModel)
        viewController.delegate = self
        viewController.hidesBottomBarWhenPushed = true
        viewController.navigationItem.largeTitleDisplayMode = .never
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func clearBrowserCacheSelected(in controller: AdvancedSettingsViewController) {
        let coordinator = ClearDappBrowserCacheCoordinator(viewController: rootViewController, analytics: analytics)
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
    }
    
    func tokenScriptSelected(in controller: AdvancedSettingsViewController) {
        let coordinator = AssetDefinitionStoreCoordinator(tokenScriptOverridesFileManager: tokenScriptOverridesFileManager, navigationController: navigationController)
        coordinator.delegate = self
        addCoordinator(coordinator)
        
        coordinator.start()
    }
    
    func changeLanguageSelected(in controller: AdvancedSettingsViewController) {
        let coordinator = LocalesCoordinator()
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
        coordinator.localesViewController.navigationItem.largeTitleDisplayMode = .never
        navigationController.pushViewController(coordinator.localesViewController, animated: true)
    }
    
    func changeCurrencySelected(in controller: AdvancedSettingsViewController) {
        let coordinator = ChangeCurrencyCoordinator(navigationController: navigationController, currencyService: currencyService)
        coordinator.delegate = self
        addCoordinator(coordinator)
        coordinator.start()
    }
    
    func analyticsSelected(in controller: AdvancedSettingsViewController) {
        let viewModel = AnalyticsViewModel(config: config)
        let controller = AnalyticsViewController(viewModel: viewModel)
        navigationController.pushViewController(controller, animated: true)
    }
    
    func usePrivateNetworkSelected(in controller: AdvancedSettingsViewController) {
        let viewModel = ChooseSendPrivateTransactionsProviderViewModel(config: config)
        let controller = ChooseSendPrivateTransactionsProviderViewController(viewModel: viewModel)
        controller.navigationItem.largeTitleDisplayMode = .never
        
        navigationController.pushViewController(controller, animated: true)
    }
    
    func exportJSONKeystoreSelected(in controller: AdvancedSettingsViewController) {
        let coordinator = ExportJsonKeystoreCoordinator(keystore: keystore, wallet: account, navigationController: navigationController)
        addCoordinator(coordinator)
        coordinator.delegate = self
        coordinator.start()
    }
    
    func featuresSelected(in controller: AdvancedSettingsViewController) {
        let controller = FeaturesViewController()
        controller.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(controller, animated: true)
    }
    
}

extension SettingsCoordinator: ChangeCurrencyCoordinatorDelegate {
    func didChangeCurrency(in coordinator: ChangeCurrencyCoordinator, currency: AlphaWalletFoundation.Currency) {
        removeCoordinator(coordinator)
        restart(for: account, reason: .currencyChange)
    }
    
    func didClose(in coordinator: ChangeCurrencyCoordinator) {
        removeCoordinator(coordinator)
    }
}

extension SettingsCoordinator: AssetDefinitionStoreCoordinatorDelegate {
    func didClose(in coordinator: AssetDefinitionStoreCoordinator) {
        removeCoordinator(coordinator)
    }
}

extension SettingsCoordinator: PingInfuraCoordinatorDelegate {
    func didPing(in coordinator: PingInfuraCoordinator) {
        removeCoordinator(coordinator)
    }
    
    func didCancel(in coordinator: PingInfuraCoordinator) {
        removeCoordinator(coordinator)
    }
}

extension SettingsCoordinator: CheckTransactionStateCoordinatorDelegate {
    func didComplete(coordinator: CheckTransactionStateCoordinator) {
        removeCoordinator(coordinator)
    }
}

extension SettingsCoordinator: ExportJsonKeystoreCoordinatorDelegate {
    func didCancel(in coordinator: ExportJsonKeystoreCoordinator) {
        removeCoordinator(coordinator)
    }
    
    func didComplete(in coordinator: ExportJsonKeystoreCoordinator) {
        removeCoordinator(coordinator)
    }
}

extension SettingsCoordinator: ClearDappBrowserCacheCoordinatorDelegate {
    func done(in coordinator: ClearDappBrowserCacheCoordinator) {
        removeCoordinator(coordinator)
    }
    
    func didCancel(in coordinator: ClearDappBrowserCacheCoordinator) {
        removeCoordinator(coordinator)
    }
}

extension SettingsCoordinator: ToolsViewControllerDelegate {
    
    func checkTransactionStateSelected(in controller: ToolsViewController) {
        let coordinator = CheckTransactionStateCoordinator(navigationController: navigationController, config: config, analytics: analytics)
        addCoordinator(coordinator)
        coordinator.delegate = self
        coordinator.start()
    }
    
    func consoleSelected(in controller: ToolsViewController) {
        delegate?.showConsole(in: self)
    }
    
    func pingInfuraSelected(in controller: ToolsViewController) {
        let coordinator = PingInfuraCoordinator(viewController: controller, analytics: analytics)
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
    }
    
    func featuresSelected(in controller: ToolsViewController) {
        let controller = FeaturesViewController()
        controller.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(controller, animated: true)
    }
}

extension SettingsCoordinator: SettingsWalletViewControllerDelegate {
    func changeWalletSelected(in controller: SettingsWalletViewController) {
        let coordinator = AccountsCoordinator(
            config: config,
            navigationController: navigationController,
            keystore: keystore,
            analytics: analytics,
            viewModel: .init(configuration: .changeWallets, animatedPresentation: true),
            walletBalanceService: walletBalanceService,
            blockiesGenerator: blockiesGenerator,
            domainResolutionService: domainResolutionService)
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
        
    }
    
    func myWalletAddressSelected(in controller: SettingsWalletViewController) {
        delegate?.didPressShowWallet(in: self)
    }
    
    func backupWalletSelected(in controller: SettingsWalletViewController) {
        guard case .real = account.type else { return }
        
        let coordinator = BackupCoordinator(navigationController: navigationController, keystore: keystore, account: account, analytics: analytics)
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
    }
    
    func showSeedPhraseSelected(in controller: SettingsWalletViewController) {
        guard case .real(let account) = account.type else { return }
        
        let coordinator = ShowSeedPhraseCoordinator(navigationController: navigationController, keystore: keystore, account: account)
        addCoordinator(coordinator)
        coordinator.delegate = self
        coordinator.start()
        
    }
    
    func nameWalletSelected(in controller: SettingsWalletViewController) {
        let viewModel = RenameWalletViewModel(account: account.address, analytics: analytics, domainResolutionService: domainResolutionService)
        let viewController = RenameWalletViewController(viewModel: viewModel)
        viewController.delegate = self
        viewController.navigationItem.largeTitleDisplayMode = .never
        viewController.hidesBottomBarWhenPushed = true
        
        navigationController.pushViewController(viewController, animated: true)
        
    }
    
    func exportJSONKeystoreSelected(in controller: SettingsWalletViewController) {
        let coordinator = ExportJsonKeystoreCoordinator(keystore: keystore, wallet: account, navigationController: navigationController)
        addCoordinator(coordinator)
        coordinator.delegate = self
        coordinator.start()
    }
    
}

extension SettingsCoordinator {

    enum PendingOperation {
        case swapToken
        case sendToken(recipient: AddressOrEnsName?)
    }
}
