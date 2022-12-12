// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import PromiseKit
import AlphaWalletWeb3
import BigInt

extension RPCServer {
    public var rpcHeaders: RPCNodeHTTPHeaders {
        switch self {
        case .klaytnCypress, .klaytnBaobabTestnet:
            let basicAuth = Constants.Credentials.klaytnRpcNodeKeyBasicAuth
            if basicAuth.isEmpty {
                return .init()
            } else {
                return [
                    "Authorization": "Basic \(basicAuth)",
                    "x-chain-id": "\(chainID)",
                ]
            }
        case .main, .classic, .callisto, .poa, .goerli, .xDai, .artis_sigma1, .artis_tau1, .binance_smart_chain, .binance_smart_chain_testnet, .heco, .heco_testnet, .custom, .fantom, .fantom_testnet, .avalanche, .avalanche_testnet, .polygon, .mumbai_testnet, .optimistic, .optimisticKovan, .cronosTestnet, .arbitrum, .arbitrumRinkeby, .palm, .palmTestnet, .ioTeX, .ioTeXTestnet, .optimismGoerli, .arbitrumGoerli, .cronosMainnet, .tomb_chain:
            return .init()
        }
    }

    func makeMaximumToBlockForEvents(fromBlockNumber: UInt64) -> EventFilter.Block {
        if let maxRange = maximumBlockRangeForEvents {
            return .blockNumber(fromBlockNumber + maxRange)
        } else {
            return .latest
        }
    }

    var web3SwiftRpcNodeBatchSupportPolicy: JSONRPCrequestDispatcher.DispatchPolicy {
        switch rpcNodeBatchSupport {
        case .noBatching:
            return .NoBatching
        case .batch(let size):
            return .Batch(size)
        }
    }
}

extension Web3 {
    private static var web3s = AtomicDictionary<RPCServer, [TimeInterval: Web3]>()

    private static let web3Queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 32
        queue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)

        return queue
    }()

    private static func createWeb3(webProvider: Web3HttpProvider, forServer server: RPCServer) -> Web3 {
        let requestDispatcher = JSONRPCrequestDispatcher(provider: webProvider, queue: web3Queue.underlyingQueue!, policy: server.web3SwiftRpcNodeBatchSupportPolicy)
        return Web3(provider: webProvider, chainID: BigUInt(server.chainID), queue: web3Queue, requestDispatcher: requestDispatcher)
    }

    public static func instance(for server: RPCServer, timeout: TimeInterval) throws -> Web3 {
        if let result = web3s[server]?[timeout] {
            return result
        } else {
            let rpcHeaders = server.rpcHeaders
            guard let webProvider = Web3HttpProvider(server.rpcURL, headers: rpcHeaders) else {
                throw Web3Error(description: "Error creating web provider for: \(server.rpcURL) + \(server.chainID)")
            }
            let configuration = webProvider.session.configuration
            configuration.timeoutIntervalForRequest = timeout
            configuration.timeoutIntervalForResource = timeout
            let session = URLSession(configuration: configuration)
            webProvider.session = session

            let result = createWeb3(webProvider: webProvider, forServer: server)
            if var timeoutsAndWeb3s = web3s[server] {
                timeoutsAndWeb3s[timeout] = result
                web3s[server] = timeoutsAndWeb3s
            } else {
                let timeoutsAndWeb3s: [TimeInterval: Web3] = [timeout: result]
                web3s[server] = timeoutsAndWeb3s
            }
            return result
        }
    }
}

fileprivate var smartContractCallsCache = AtomicDictionary<String, (promise: Promise<[String: Any]>, timestamp: Date)>()
private let callSmartContractQueue = DispatchQueue(label: "com.callSmartContractQueue.updateQueue")
//`shouldDelayIfCached` is a hack for TokenScript views
//TODO should trap 429 from RPC node
public func callSmartContract(withServer server: RPCServer, contract contractAddress: AlphaWallet.Address, functionName: String, abiString: String, parameters: [AnyObject] = [], shouldDelayIfCached: Bool = false) -> Promise<[String: Any]> {
    firstly {
        .value(server)
    }.then(on: callSmartContractQueue, { [callSmartContractQueue] server -> Promise<[String: Any]> in
        let cacheKey = "\(contractAddress).\(functionName) \(parameters) \(server.chainID)"
        let ttlForCache: TimeInterval = 10
        let now = Date()

        if let (cachedPromise, cacheTimestamp) = smartContractCallsCache[cacheKey], now.timeIntervalSince(cacheTimestamp) < ttlForCache {
            //HACK: We can't return the cachedPromise directly and immediately because if we use the value as a TokenScript attribute in a TokenScript view, timing issues will cause the webview to not load properly or for the injection with updates to fail
            return after(seconds: shouldDelayIfCached ? 0.7 : 0).then(on: callSmartContractQueue, { _ -> Promise<[String: Any]> in return cachedPromise })
        } else {
            let web3 = try Web3.instance(for: server, timeout: 60)
            let contract = try Web3.Contract(web3: web3, abiString: abiString, at: EthereumAddress(address: contractAddress))
            let promiseCreator = try contract.method(functionName, parameters: parameters)

            var web3Options = Web3Options()
            web3Options.excludeZeroGasPrice = server.shouldExcludeZeroGasPrice

            let promise: Promise<[String: Any]> = promiseCreator.callPromise(options: web3Options)
                .recover(on: callSmartContractQueue, { error -> Promise<[String: Any]> in
                        //NOTE: We only want to log rate limit errors above
                    guard case AlphaWalletWeb3.Web3Error.rateLimited = error else { throw error }
                    warnLog("[API] Rate limited by RPC node server: \(server)")

                    throw error
                })

            smartContractCallsCache[cacheKey] = (promise, now)

            return promise
        }
    })
}

public func getSmartContractCallData(withServer server: RPCServer, contract contractAddress: AlphaWallet.Address, functionName: String, abiString: String, parameters: [AnyObject] = []) -> Data? {
    guard let web3 = try? Web3.instance(for: server, timeout: 60) else { return nil }
    guard let contract = try? Web3.Contract(web3: web3, abiString: abiString, at: EthereumAddress(address: contractAddress), options: web3.options) else { return nil }
    guard let promiseCreator = try? contract.method(functionName, parameters: parameters, options: nil) else { return nil }
    return promiseCreator.transaction.data
}

final class GetEventLogs {
    private let queue = DispatchQueue(label: "org.alphawallet.swift.eth.getEventLogs", qos: .utility)
    private var inFlightPromises: [String: Promise<[EventParserResultProtocol]>] = [:]

    func getEventLogs(contractAddress: AlphaWallet.Address, server: RPCServer, eventName: String, abiString: String, filter: EventFilter) -> Promise<[EventParserResultProtocol]> {
        firstly {
            .value(contractAddress)
        }.then(on: queue, { [weak self, queue] contractAddress -> Promise<[EventParserResultProtocol]> in
            let key = "\(contractAddress.eip55String)-\(server.chainID)-\(eventName)-\(abiString)-\(try JSONEncoder().encode(filter.rpcPreEncode()).hashValue)"

            if let promise = self?.inFlightPromises[key] {
                return promise
            } else {
                let web3 = try Web3.instance(for: server, timeout: 60)
                let contract = try Web3.Contract(web3: web3, abiString: abiString, at: EthereumAddress(address: contractAddress), options: web3.options)

                let promise = contract
                    .getIndexedEventsPromise(eventName: eventName, filter: filter)
                    .ensure(on: queue, { self?.inFlightPromises[key] = .none })

                self?.inFlightPromises[key] = promise

                return promise
            }
        }).recover(on: queue, { error -> Promise<[EventParserResultProtocol]> in
            warnLog("[eth_getLogs] failure for server: \(server) with error: \(error)")
            throw error
        })
    }
}
