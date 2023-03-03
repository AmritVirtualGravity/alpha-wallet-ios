//
//  SelectServiceToBuyCryptoCoordinator.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 23.08.2022.
//

import UIKit
import AlphaWalletFoundation
import Ramp
import AlphaWalletCore

protocol SelectServiceToBuyCryptoCoordinatorDelegate: AnyObject, CanOpenURL {
    func selectBuyService(_ result: Result<Void, BuyCryptoError>, in coordinator: SelectServiceToBuyCryptoCoordinator)
    func didClose(in coordinator: SelectServiceToBuyCryptoCoordinator)
}

class SelectServiceToBuyCryptoCoordinator: Coordinator {
    private let token: TokenActionsIdentifiable
    private let viewController: UIViewController
    private let source: Analytics.BuyCryptoSource
    private let analytics: AnalyticsLogger
    private let buyTokenProvider: BuyTokenProvider
    var coordinators: [Coordinator] = []
    weak var delegate: SelectServiceToBuyCryptoCoordinatorDelegate?

    init(buyTokenProvider: BuyTokenProvider, token: TokenActionsIdentifiable, viewController: UIViewController, source: Analytics.BuyCryptoSource, analytics: AnalyticsLogger) {
        self.buyTokenProvider = buyTokenProvider
        self.token = token
        self.viewController = viewController
        self.source = source
        self.analytics = analytics
    }

    func start(wallet: Wallet) {
        selectBuyService(wallet: wallet, completion: { result in
            switch result {
            case .service(let service):
                self.runThirdParty(wallet: wallet, service: service)
                self.delegate?.selectBuyService(.success(()), in: self)
            case .failure(let error):
                self.delegate?.selectBuyService(.failure(error), in: self)
            case .canceled:
                self.delegate?.didClose(in: self)
            }
        })
    }

    private func runThirdParty(wallet: Wallet, service: BuyTokenURLProviderType & SupportedTokenActionsProvider) {
//        let coordinator = BuyCryptoUsingThirdPartyCoordinator(service: service, token: token, viewController: viewController, source: source, analytics: analytics)
//        coordinator.delegate = self
//        addCoordinator(coordinator)
//        coordinator.start(wallet: wallet)
        var configuration = Configuration()
        let isFromPopAction = UserDefaults.standard.bool(forKey: "FromPupAction")
       
        configuration.swapAsset = isFromPopAction ? "" :  getSwapAsset(for: token)
        configuration.hostApiKey = Constants.Credentials.rampApiKey
        configuration.userAddress = wallet.address.eip55String
        let ramp = try! RampViewController(configuration: configuration)
        ramp.delegate = self
        self.viewController.present(ramp, animated: true)
    }

    private enum BuyCryptoUsingService {
        case service(BuyTokenURLProviderType & SupportedTokenActionsProvider)
        case failure(error: BuyCryptoError)
        case canceled
    }

    private func selectBuyService(wallet: Wallet, completion: @escaping (BuyCryptoUsingService) -> Void) {
        typealias ActionToService = (service: BuyTokenURLProviderType & SupportedTokenActionsProvider, action: UIAlertAction)

        let actions = buyTokenProvider.services.compactMap { service -> ActionToService? in
            guard service.isSupport(token: token) && service.url(token: token, wallet: wallet) != nil else { return nil }

            return (service, UIAlertAction(title: service.action, style: .default) { _ in completion(.service(service)) })
        }

        if actions.isEmpty {
            completion(.failure(error: BuyCryptoError.buyNotSupported))
        } else if actions.count == 1 {
            completion(.service(actions[0].service))
        } else {
            let alertController = UIAlertController(title: nil, message: .none, preferredStyle: .actionSheet)
            for each in actions {
                alertController.addAction(each.action)
            }

            alertController.addAction(UIAlertAction(title: R.string.localizable.cancel(), style: .cancel) { _ in completion(.canceled) })
            viewController.present(alertController, animated: true)
        }
    }
}

extension SelectServiceToBuyCryptoCoordinator: BuyCryptoUsingThirdPartyCoordinatorDelegate {
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


extension SelectServiceToBuyCryptoCoordinator: RampDelegate {
    func rampDidClose(_ rampViewController: RampViewController) {
        //
       
        self.viewController.viewWillAppear(true)
    }
    
    func ramp(_ rampViewController: RampViewController, didCreateOnrampPurchase purchase:OnrampPurchase, _ purchaseViewToken: String, _ apiUrl: URL) {
        //
    }
    
    func ramp(_ rampViewController: RampViewController, didRequestSendCrypto payload: SendCryptoPayload, responseHandler: @escaping (SendCryptoResultPayload) -> Void) {
        //
    }
    
    func ramp(_ rampViewController: RampViewController, didCreateOfframpSale sale: OfframpSale, _ saleViewToken: String, _ apiUrl: URL) {
        //
    }
}

extension SelectServiceToBuyCryptoCoordinator {
    public func getBuyRampList() -> [String] {
        return    ["ARBITRUM_ETH", "AVAX_AVAX", "AVAX_USDC", "BCH_BCH", "BSC_BNB",  "BSC_BUSD", "BSC_FEVR","BTC_BTC","CARDANO_ADA", "CELO_CELO", "CELO_CEUR", "CELO_CREAL", "CELO_CUSD","COSMOS_ATOM","DOGE_DOGE","ELROND_EGLD","ETH_BAT", "ETH_DAI", "ETH_ENS", "ETH_ETH",  "ETH_FEVR",  "ETH_LINK",  "ETH_MANA","ETH_RLY","ETH_SAND", "ETH_USDC",  "ETH_USDT", "FANTOM_FTM", "FILECOIN_FIL", "FLOW_FLOW", "FLOW_FUSD", "FLOW_USDC", "FUSE_FUSD", "HARMONY_ONE","IMMUTABLEX_ETH", "KUSAMA_KSM", "LTC_LTC","MATIC_BAT", "MATIC_DAI", "MATIC_ETH", "MATIC_MANA", "MATIC_MATIC",  "MATIC_OVR","MATIC_SAND", "MATIC_USDC", "NEAR_NEAR","OKC_OKT","OPTIMISM_DAI","OPTIMISM_ETH","POLKADOT_DOT", "RONIN_AXS","RONIN_RON",  "RONIN_SLP",   "RONIN_WETH", "RSK_RDOC", "RSK_RIF","SOLANA_BAT","SOLANA_KIN",   "SOLANA_RLY", "SOLANA_SOL",  "SOLANA_USDC",   "SOLANA_USDT", "STARKNET_ETH",  "TEZOS_XTZ", "XDAI_XDAI","XLM_XLM", "XRP_XRP","ZILLIQA_ZIL",  "ZKSYNC_DAI",  "ZKSYNC_ETH","ZKSYNC_USDC","ZKSYNC_USDT","ZKSYNC_WBTC"]
    }
    
    public func getSwapAsset(for token: TokenActionsIdentifiable) -> String {
        let chainSymbol = mapChainSymbolForRamp(token: token)
        return (chainSymbol + "_" + token.symbol).uppercased()
    }
    
    public func mapChainSymbolForRamp(token: TokenActionsIdentifiable) -> String {
        switch token.server {
        case .fantom:
            return "FANTOM"
        case.binance_smart_chain:
            return "BSC"
        case.arbitrum:
            return "ARBITRUM"
        case.optimistic:
            return "OPTIMISM"
        default:
            return token.server.symbol
        }
    }
    
    public func isTokenOnRamp(swapAsset: String) -> Bool {
        return getBuyRampList().contains {
            $0 == swapAsset
        }
    }
}
