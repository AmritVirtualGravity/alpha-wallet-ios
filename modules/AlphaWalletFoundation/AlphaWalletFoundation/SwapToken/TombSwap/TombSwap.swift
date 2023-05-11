//
//  TombSwap.swift
//  Alamofire
//
//  Created by ebpearls on 11/05/2023.
//

import Foundation
import Combine

public class TombSwap: SupportedTokenActionsProvider, SwapTokenViaUrlProvider {
    public var objectWillChange: AnyPublisher<Void, Never> {
        return .empty()
    }

    public let action: String

    public func rpcServer(forToken token: TokenActionsIdentifiable) -> RPCServer? {
        return .tomb_chain
    }
    public let analyticsNavigation: Analytics.Navigation = .onQuickSwap
    public let analyticsName: String = "TombSwap"
// https://tombchain.lif3.com/swap?inputCurrency={token-address}
    private static let baseURL = "https://tombchain.lif3.com"

    public var version: Version = .v2
    public var theme: Uniswap.Theme = .dark
    public var method: Method = .swap

    public func url(token: TokenActionsIdentifiable) -> URL? {
        let input = Input.input(token.contractAddress)
        var components = URLComponents()
        components.path = method.rawValue
        components.queryItems = [
            URLQueryItem(name: Version.key, value: version.rawValue),
            URLQueryItem(name: Uniswap.Theme.key, value: theme.rawValue)
        ] + input.urlQueryItems

        //NOTE: URLComponents doesn't allow path to contain # symbol
        guard let pathWithQueryItems = components.url?.absoluteString else { return nil }

        return URL(string: TombSwap.baseURL + pathWithQueryItems)
    }

    public enum Version: String {
        static let key = "use"

        case v1
        case v2
    }

    public enum Method: String {
        case swap = "/swap"
        case use
    }

    enum Input {
        enum Keys {
            static let input = "inputCurrency"
            static let output = "outputCurrency"
        }

        case inputOutput(from: AlphaWallet.Address, to: AddressOrEnsName)
        case input(AlphaWallet.Address)
        case none

        var urlQueryItems: [URLQueryItem] {
            switch self {
            case .inputOutput(let inputAddress, let outputAddress):
                return [
                    .init(name: Keys.input, value: functional.rewriteContractInput(inputAddress)),
                    .init(name: Keys.output, value: outputAddress.stringValue),
                ]
            case .input(let address):
                return [
                    .init(name: Keys.input, value: functional.rewriteContractInput(address))
                ]
            case .none:
                return []
            }
        }

        class functional {
            static func rewriteContractInput(_ address: AlphaWallet.Address) -> String {
                if address == Constants.nativeCryptoAddressInDatabase {
                    //QuickSwap (forked from Uniswap) likes it this way
                    return "ETH"
                } else {
                    return address.eip55String
                }
            }
        }
    }

    public init(action: String) {
        self.action = action
    }

    public func actions(token: TokenActionsIdentifiable) -> [TokenInstanceAction] {
        return [
            .init(type: .swap(service: self))
        ]
    }

    public func isSupport(token: TokenActionsIdentifiable) -> Bool {
        switch token.server {
        case .tomb_chain:
            return true
        default:
            return false
        }
    }

    public func start() {
        //no-op
    }
}
