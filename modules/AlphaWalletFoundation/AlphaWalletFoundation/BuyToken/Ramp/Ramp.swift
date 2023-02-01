//
//  Ramp.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 03.03.2021.
//

import Foundation
import Combine
import AlphaWalletCore
import AlphaWalletLogger

public final class Ramp: SupportedTokenActionsProvider, BuyTokenURLProviderType {
    private var objectWillChangeSubject = PassthroughSubject<Void, Never>()
    private (set) public var assets: Swift.Result<[Asset], Error> = .failure(RampError())
    private let queue: DispatchQueue = .init(label: "org.alphawallet.swift.Ramp")
    private var cancelable = Set<AnyCancellable>()
    private let reachability: ReachabilityManagerProtocol
    private let networkProvider: RampNetworkProviderType
    private let retryBehavior: RetryBehavior<RunLoop>
    
    public var objectWillChange: AnyPublisher<Void, Never> {
        objectWillChangeSubject
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    public let analyticsNavigation: Analytics.Navigation = .onRamp
    public let analyticsName: String = "Ramp"
    public let action: String

    public init(action: String, networkProvider: RampNetworkProviderType, reachability: ReachabilityManagerProtocol = ReachabilityManager(), retryBehavior: RetryBehavior<RunLoop> = Oneinch.defaultRetryBehavior) {
        self.action = action
        self.reachability = reachability
        self.networkProvider = networkProvider
        self.retryBehavior = retryBehavior
    }
    
    deinit {
        infoLog("\(self).deinit")
    }
    
    public func url(token: TokenActionsIdentifiable, wallet: Wallet) -> URL? {
        let symbol = getSwapAsset(for: token)
        if let url = URL(string: Constants.buyWithRampUrl(asset: symbol, wallet: wallet) ?? "") {
            return url
        }
        return nil
        
//        return symbol
//            .flatMap { Constants.buyWithRampUrl(asset: $0, wallet: wallet) }
//            .flatMap { URL(string: $0) }
    }
    
    public func actions(token: TokenActionsIdentifiable) -> [TokenInstanceAction] {
        return [.init(type: .buy(service: self))]
    }
    
    public func isSupport(token: TokenActionsIdentifiable) -> Bool {
        return isTokenOnRamp(swapAsset: getSwapAsset(for: token))
//        return asset(for: token) != nil
    }
    private func asset(for token: TokenActionsIdentifiable) -> Asset? {
        //We only operate for mainnets. This is because we store native cryptos for Ethereum testnets like `.goerli` with symbol "ETH" which would match Ramp's Ethereum token
        func isAssetMatchesForToken(token: TokenActionsIdentifiable, asset: Asset) -> Bool {
            return asset.symbol.lowercased() == token.symbol.trimmingCharacters(in: .controlCharacters).lowercased()
                    && asset.decimals == token.decimals
                    && (asset.address == nil ? token.contractAddress == Constants.nativeCryptoAddressInDatabase : asset.address! == token.contractAddress)
        }
        
        guard !token.server.isTestnet else { return nil }
        switch assets {
        case .success(let assets):
            return assets.first(where: { isAssetMatchesForToken(token: token, asset: $0) })
        case .failure:
            return nil
        }
    }
    
    public func getBuyRampList() -> [String] {
        return    ["ARBITRUM_ETH", "AVAX_AVAX", "AVAX_USDC", "BCH_BCH", "BSC_BNB",  "BSC_BUSD", "BSC_FEVR","BTC_BTC","CARDANO_ADA", "CELO_CELO", "CELO_CEUR", "CELO_CREAL", "CELO_CUSD","COSMOS_ATOM","DOGE_DOGE","ELROND_EGLD","ETH_BAT", "ETH_DAI", "ETH_ENS", "ETH_ETH",  "ETH_FEVR",  "ETH_LINK",  "ETH_MANA","ETH_RLY","ETH_SAND", "ETH_USDC",  "ETH_USDT", "FANTOM_FTM", "FILECOIN_FIL", "FLOW_FLOW", "FLOW_FUSD", "FLOW_USDC", "FUSE_FUSD", "HARMONY_ONE","IMMUTABLEX_ETH", "KUSAMA_KSM", "LTC_LTC","MATIC_BAT", "MATIC_DAI", "MATIC_ETH", "MATIC_MANA", "MATIC_MATIC",  "MATIC_OVR","MATIC_SAND", "MATIC_USDC", "NEAR_NEAR","OKC_OKT","OPTIMISM_DAI","OPTIMISM_ETH","POLKADOT_DOT", "RONIN_AXS","RONIN_RON",  "RONIN_SLP",   "RONIN_WETH", "RSK_RDOC", "RSK_RIF","SOLANA_BAT","SOLANA_KIN",   "SOLANA_RLY", "SOLANA_SOL",  "SOLANA_USDC",   "SOLANA_USDT", "STARKNET_ETH",  "TEZOS_XTZ", "XDAI_XDAI","XLM_XLM", "XRP_XRP","ZILLIQA_ZIL",  "ZKSYNC_DAI",  "ZKSYNC_ETH","ZKSYNC_USDC","ZKSYNC_USDT","ZKSYNC_WBTC"]
    }
    
    public func getSwapAsset(for token: TokenActionsIdentifiable) -> String {
        var chainSymbol = mapChainSymbolForRamp(token: token)
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
    
    public func start() {
        reachability.networkBecomeReachablePublisher
            .receive(on: queue)
            .setFailureType(to: PromiseError.self)
            .flatMapLatest { [networkProvider, retryBehavior] _ -> AnyPublisher<[Asset], PromiseError> in
                networkProvider.retrieveAssets()
                    .retry(retryBehavior, scheduler: RunLoop.main)
                    .eraseToAnyPublisher()
            }.receive(on: queue)
            .sink { [objectWillChangeSubject] result in
                objectWillChangeSubject.send(())
                
                guard case .failure(let error) = result else { return }
                let request = RampNetworkProvider.RampRequest()
                RemoteLogger.instance.logRpcOrOtherWebError("Ramp error | \(error)", url: request.urlRequest?.url?.absoluteString ?? "")
            } receiveValue: {
                self.assets = .success($0)
            }.store(in: &cancelable)
    }
    
//    public func getSymbolForBuyRamp(assetSymbol: String, chainSymbol:String, type: AlphaWalletFoundation.TokenType) -> String {
//        if type == .nativeCryptocurrency {
//            switch assetSymbol {
//            case "FTM":// fantom
//                return "FANTOM_FTM".lowercased()
//            case "BNB": //BNB on Binance Smart Chain
//                return "BSC_BNB".lowercased()
//            case "AETH": // arbitrum on etherum
//                return "ARBITRUM_ETH".lowercased()
//            default:
//                return assetSymbol.lowercased()
//            }
//        } else {
//            return (chainSymbol + "_" + assetSymbol).lowercased()
//        }
//    }
    
}
