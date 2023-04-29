// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt

extension RPCServer {
    public static func custom(chainId: Int) -> RPCServer {
        return .custom(.custom(chainId: chainId))
    }
}

// swiftlint:disable type_body_length
public enum RPCServer: Hashable, CaseIterable {
    
    enum RpcNodeBatchSupport {
        case noBatching
        case batch(Int)
    }

    public static var customRpcs: [CustomRPC] = RPCServer.convertJsonToCustomRpcs(Config().customRpcServersJson) {
        didSet {
            if let data = try? JSONEncoder().encode(customRpcs), let json = String(data: data, encoding: .utf8) {
                var c = Config()
                c.customRpcServersJson = json
                customServers = customRpcs.map { RPCServer.custom($0) }
            } else {
                //no-op
            }
        }
    }
    public private(set) static var customServers: [Self] = customRpcs.map { RPCServer.custom($0) }
    case main
    case poa
    case classic
    //As of 20210601, `.callisto` doesn't eth_blockNumber because their endpoint requires including `"params": []` in the payload even if it's empty and we don't.
    //As of 20210601, `.callisto` doesn't support eth_call according to https://testnet-explorer.callisto.network/eth-rpc-api-docs
    case callisto
    case xDai
    case goerli
    case artis_sigma1
    case artis_tau1
    case binance_smart_chain
    case binance_smart_chain_testnet
    case heco
    case heco_testnet
    case fantom
    case fantom_testnet
    case avalanche
    case avalanche_testnet
    case polygon
    case mumbai_testnet
    case optimistic
    case cronosMainnet
    case cronosTestnet
    case custom(CustomRPC)
    case arbitrum
    case palm
    case palmTestnet
    case klaytnCypress
    case klaytnBaobabTestnet
    case ioTeX
    case ioTeXTestnet
    case optimismGoerli
    case arbitrumGoerli
    case tomb_chain
    case metis

    public enum EtherscanCompatibleType: String, Codable {
        case etherscan
        case blockscout
        case unknown
    }

    //Using this property avoids direct reference to `.main`, which could be a sign of a possible crash — i.e. using `.main` when it is disabled by the user
    public static var forResolvingEns: RPCServer {
        .main
    }

    public var isDeprecated: Bool {
        return false
    }

    public var chainID: Int {
        switch self {
        case .main: return 1
        case .poa: return 99
        case .classic: return 61
        case .callisto: return 104729
        case .xDai: return 100
        case .goerli: return 5
        case .artis_sigma1: return 246529
        case .artis_tau1: return 246785
        case .binance_smart_chain: return 56
        case .binance_smart_chain_testnet: return 97
        case .heco: return 128
        case .heco_testnet: return 256
        case .custom(let custom): return custom.chainID
        case .fantom: return 250
        case .fantom_testnet: return 0xfa2
        case .avalanche: return 0xa86a
        case .avalanche_testnet: return 0xa869
        case .polygon: return 137
        case .mumbai_testnet: return 80001
        case .optimistic: return 10
        case .cronosTestnet: return 338
        case .cronosMainnet: return 25
        case .arbitrum: return 42161
        case .palm: return 11297108109
        case .palmTestnet: return 11297108099
        case .klaytnCypress: return 8217
        case .klaytnBaobabTestnet: return 1001
        case .ioTeX: return 4689
        case .ioTeXTestnet: return 4690
        case .optimismGoerli: return 420
        case .arbitrumGoerli: return 421613
        case .tomb_chain: return 6969
        case .metis: return 1088
        }
    }

    public var name: String {
        switch self {
        case .main: return "Ethereum"
        case .poa: return "POA Network"
        case .classic: return "Ethereum Classic"
        case .callisto: return "Callisto"
        case .xDai: return "Gnosis"
        case .goerli: return "Goerli"
        case .artis_sigma1: return "ARTIS sigma1"
        case .artis_tau1: return "ARTIS tau1"
        case .binance_smart_chain: return "BNB Chain"
        case .binance_smart_chain_testnet: return "Binance (BSC) Testnet"
        case .heco: return "Heco"
        case .heco_testnet: return "Heco Testnet"
        case .custom(let custom): return custom.chainName
        case .fantom: return "Fantom Opera"
        case .fantom_testnet: return "Fantom Testnet"
        case .avalanche: return "Avalanche"
        case .avalanche_testnet: return "Avalanche FUJI C-Chain"
        case .polygon: return "Polygon"
        case .mumbai_testnet: return "Mumbai Testnet"
        case .optimistic: return "Optimism"
        case .cronosMainnet: return "Cronos"
        case .cronosTestnet: return "Cronos Testnet"
        case .arbitrum: return "Arbitrum One"
        case .palm: return "Palm"
        case .palmTestnet: return "Palm (Testnet)"
        case .klaytnCypress: return "Klaytn Cypress"
        case .klaytnBaobabTestnet: return "Klaytn Baobab"
        case .ioTeX: return "IoTeX Mainnet"
        case .ioTeXTestnet: return "IoTeX Testnet"
        case .optimismGoerli: return "Optimism Goerli"
        case .arbitrumGoerli: return "Arbitrum Goerli"
        case .tomb_chain: return "Tomb Chain"
        case .metis: return "Metis"
        }
    }

    public var isTestnet: Bool {
        switch self {
        case .xDai, .classic, .main, .poa, .callisto, .binance_smart_chain, .artis_sigma1, .heco, .fantom, .avalanche, .polygon, .optimistic, .arbitrum, .palm, .klaytnCypress, .ioTeX, .cronosMainnet, .tomb_chain, .metis:
            return false
        case .goerli, .artis_tau1, .binance_smart_chain_testnet, .heco_testnet, .fantom_testnet, .avalanche_testnet, .mumbai_testnet, .cronosTestnet, .palmTestnet, .klaytnBaobabTestnet, .ioTeXTestnet, .optimismGoerli, .arbitrumGoerli:
            return true
        case .custom(let custom):
            return custom.isTestnet
        }
    }

    public var customRpc: CustomRPC? {
        guard case .custom(let customRpc) = self else { return nil }
        return customRpc
    }

    public var isCustom: Bool {
        customRpc != nil
    }
    #warning("need more info")
    private var etherscanURLForGeneralTransactionHistory: URL? {
        switch self {
        case .main, .poa, .classic, .goerli, .xDai, .artis_sigma1, .artis_tau1, .polygon, .binance_smart_chain, .binance_smart_chain_testnet, .callisto, .optimistic, .cronosMainnet, .cronosTestnet, .custom, .arbitrum, .palm, .palmTestnet, .optimismGoerli, .arbitrumGoerli, .avalanche, .avalanche_testnet, .tomb_chain, .metis:
            return etherscanApiRoot?.appendingQueryString("module=account&action=txlist")
        case .heco: return nil
        case .heco_testnet: return nil
        case .fantom: return nil
        case .fantom_testnet: return nil
        case .mumbai_testnet: return nil
        case .klaytnCypress, .klaytnBaobabTestnet: return nil
        case .ioTeX, .ioTeXTestnet: return nil
        }
    }

    ///etherscan-compatible erc20 transaction event APIs
    ///The fetch ERC20 transactions endpoint from Etherscan returns only ERC20 token transactions but the Blockscout version also includes ERC721 transactions too (so it's likely other types that it can detect will be returned too); thus we should check the token type rather than assume that they are all ERC20
    private var etherscanURLForTokenTransactionHistory: URL? {
        switch etherscanCompatibleType {
        case .etherscan, .blockscout: return etherscanApiRoot?.appendingQueryString("module=account&action=tokentx")
        case .unknown: return nil
        }
    }
    #warning("need more info")
    var etherscanWebpageRoot: URL? {
        let urlString: String? = {
            switch self {
            case .main: return "https://cn.etherscan.com"
            case .goerli: return "https://goerli.etherscan.io"
            case .heco_testnet: return "https://testnet.hecoinfo.com"
            case .heco: return "https://hecoinfo.com"
            case .fantom: return "https://ftmscan.com"
            case .xDai: return "https://blockscout.com/poa/dai"
            case .poa: return "https://blockscout.com/poa/core"
            case .classic: return "https://blockscout.com/etc/mainnet"
            case .callisto: return "https://explorer.callisto.network"
            case .artis_sigma1: return "https://explorer.sigma1.artis.network"
            case .artis_tau1: return "https://explorer.tau1.artis.network"
            case .binance_smart_chain: return "https://bscscan.com"
            case .binance_smart_chain_testnet: return "https://testnet.bscscan.com"
            case .polygon: return "https://polygonscan.com"
            case .mumbai_testnet: return "https://mumbai.polygonscan.com"
            case .optimistic: return "https://optimistic.etherscan.io"
            case .cronosMainnet: return "https://cronoscan.com"
            case .cronosTestnet: return "https://cronos-explorer.crypto.org"
            case .custom: return nil
            case .fantom_testnet: return nil
            case .avalanche: return "https://snowtrace.io"
            case .avalanche_testnet: return "https://testnet.snowtrace.io"
            case .arbitrum: return "https://arbiscan.io"
            case .palm: return "https://explorer.palm.io"
            case .palmTestnet: return "https://explorer.palm-uat.xyz"
            case .klaytnCypress: return "https://scope.klaytn.com"
            case .klaytnBaobabTestnet: return "https://baobab.scope.klaytn.com"
            case .ioTeX: return "https://iotexscan.io"
            case .ioTeXTestnet: return "https://testnet.iotexscan.io"
            case .optimismGoerli: return "https://goerli-rollup-explorer.arbitrum.io"
            case .arbitrumGoerli: return "https://blockscout.com/optimism/goerli"
            case .tomb_chain: return "https://tombscout.com"
            case .metis: return "https://andromeda-explorer.metis.io/"
            }
        }()
        return urlString.flatMap { URL(string: $0) }
    }
    #warning("need more info")
    var etherscanApiRoot: URL? {
        let urlString: String? = {
            switch self {
            case .main: return "https://api-cn.etherscan.com/api"
            case .goerli: return "https://api-goerli.etherscan.io/api"
            case .classic: return "https://blockscout.com/etc/mainnet/api"
            case .callisto: return "https://explorer.callisto.network/api"
            case .poa: return "https://blockscout.com/poa/core/api"
            case .xDai: return "https://blockscout.com/poa/xdai/api"
            case .artis_sigma1: return "https://explorer.sigma1.artis.network/api"
            case .artis_tau1: return "https://explorer.tau1.artis.network/api"
            case .binance_smart_chain: return "https://api.bscscan.com/api"
            case .binance_smart_chain_testnet: return "https://api-testnet.bscscan.com/api"
            case .heco_testnet: return "https://api-testnet.hecoinfo.com/api"
            case .heco: return "https://api.hecoinfo.com/api"
            case .custom(let custom):
                return custom.explorerEndpoint
                        .flatMap { URL(string: $0) }
                        .flatMap { $0.appendingPathComponent("api").absoluteString }
            case .fantom: return "https://api.ftmscan.com/api"
            //TODO fix etherscan-compatible API endpoint
            case .fantom_testnet: return "https://explorer.testnet.fantom.network/tx/api"
            case .avalanche: return "https://api.snowtrace.io/api"
            case .avalanche_testnet: return "https://api-testnet.snowtrace.io"
            case .polygon: return "https://api.polygonscan.com/api"
            case .mumbai_testnet: return "https://api-testnet.polygonscan.com/api"
            case .optimistic: return "https://api-optimistic.etherscan.io/api"
            case .cronosMainnet: return "https://api.cronoscan.com/api"
            case .cronosTestnet: return "https://cronos-explorer.crypto.org/api"
            case .arbitrum: return "https://api.arbiscan.io/api"
            case .palm: return "https://explorer.palm.io/api"
            case .palmTestnet: return "https://explorer.palm-uat.xyz/api"
            case .klaytnCypress: return "https://klaytn-mainnet.blockscout.com/api"
            case .klaytnBaobabTestnet: return "https://klaytn-testnet.blockscout.com/api"
            case .ioTeX: return nil
            case .ioTeXTestnet: return nil
            case .optimismGoerli: return "https://goerli-rollup-explorer.arbitrum.io/api"
            case .arbitrumGoerli: return "https://blockscout.com/optimism/goerli/api"
            case .tomb_chain: return "https://tombscout.com/api"
            case .metis: return "https://andromeda-explorer.metis.io/api"
            }
        }()
        return urlString.flatMap { URL(string: $0) }
    }

    //If Etherscan, action=tokentx for ERC20 and action=tokennfttx for ERC721. If Blockscout-compatible, action=tokentx includes both ERC20 and ERC721. tokennfttx is not supported.
    private var etherscanURLForERC721TransactionHistory: URL? {
        switch etherscanCompatibleType {
        case .etherscan: return etherscanApiRoot?.appendingQueryString("module=account&action=tokennfttx")
        case .blockscout: return etherscanApiRoot?.appendingQueryString("module=account&action=tokentx")
        case .unknown: return nil
        }
    }
    #warning("need more info")
    private var etherscanCompatibleType: EtherscanCompatibleType {
        switch self {
        case .main, .goerli, .fantom, .heco, .heco_testnet, .optimistic, .binance_smart_chain, .binance_smart_chain_testnet, .polygon, .arbitrum, .cronosMainnet, .avalanche, .avalanche_testnet, .tomb_chain:
            return .etherscan
        case .arbitrumGoerli, .optimismGoerli:
            return .blockscout
        case .poa, .classic, .xDai, .artis_sigma1, .artis_tau1, .mumbai_testnet, .callisto, .cronosTestnet, .palm, .palmTestnet, .metis:
            return .blockscout
        case .fantom_testnet:
            return .unknown
        case .klaytnCypress, .klaytnBaobabTestnet: return .blockscout
        case .custom(let custom):
            return custom.etherscanCompatibleType
        case .ioTeX, .ioTeXTestnet: return .etherscan
        }
    }

    var etherscanApiKey: String? {
        switch self {
        case .main, .goerli, .optimistic, .arbitrum, .optimismGoerli: return Constants.Credentials.etherscanKey
        case .binance_smart_chain: return Constants.Credentials.binanceSmartChainExplorerApiKey //Key not needed for testnet (empirically)
        case .polygon, .mumbai_testnet: return Constants.Credentials.polygonScanExplorerApiKey
        case .avalanche: return Constants.Credentials.avalancheExplorerApiKey
        case .fantom, .heco, .heco_testnet, .binance_smart_chain_testnet: return nil
        case .klaytnCypress, .klaytnBaobabTestnet: return nil
        case .poa, .classic, .xDai, .artis_sigma1, .artis_tau1, .callisto, .fantom_testnet, .avalanche_testnet, .cronosTestnet, .palm, .palmTestnet, .custom, .cronosMainnet: return nil
        case .ioTeX, .ioTeXTestnet: return nil
        case .optimismGoerli, .arbitrumGoerli: return nil
        case .tomb_chain: return nil
        case .metis: return nil
        }
    }
    #warning("need more info")
    //Some chains like Optimistic have the native token share the same balance as a distinct ERC20 token. On such chains, we must not show both of them at the same time
    var erc20AddressForNativeToken: AlphaWallet.Address? {
        switch self {
        case .optimistic: return AlphaWallet.Address(string: "0x4200000000000000000000000000000000000006")!
        case .tomb_chain: return AlphaWallet.Address(string: "0xDeadDeAddeAddEAddeadDEaDDEAdDeaDDeAD0000")!
        case .main, .goerli, .fantom, .heco, .heco_testnet, .binance_smart_chain, .binance_smart_chain_testnet, .polygon, .poa, .classic, .xDai, .artis_sigma1, .artis_tau1, .mumbai_testnet, .callisto, .cronosTestnet, .fantom_testnet, .avalanche, .avalanche_testnet, .custom, .arbitrum, .palm, .palmTestnet, .optimismGoerli, .cronosMainnet: return nil
        case .klaytnCypress, .klaytnBaobabTestnet: return nil
        case .ioTeX, .ioTeXTestnet: return nil
        case .optimismGoerli, .arbitrumGoerli: return nil
        case .metis: return AlphaWallet.Address(string: "0x9e32b13ce7f2e80a01932b42553652e053d6ed8e")!
        }
    }
    #warning("need more info")
    //Optimistic don't allow changing the gas price and limit
    public var canUserChangeGas: Bool {
        switch self {
        case .main, .goerli, .fantom, .heco, .heco_testnet, .binance_smart_chain, .binance_smart_chain_testnet, .polygon, .poa, .classic, .xDai, .artis_sigma1, .artis_tau1, .mumbai_testnet, .callisto, .cronosTestnet, .fantom_testnet, .avalanche, .avalanche_testnet, .custom, .arbitrum, .palm, .palmTestnet, .optimismGoerli, .cronosMainnet, .tomb_chain, .metis: return true
        case .optimistic, .klaytnCypress, .klaytnBaobabTestnet, .ioTeX, .ioTeXTestnet: return false
        case .optimismGoerli, .arbitrumGoerli: return false
        }
    }

    var shouldAddBufferWhenEstimatingGasPrice: Bool {
        switch self {
        case .main, .poa, .classic, .callisto, .xDai, .goerli, .artis_sigma1, .artis_tau1, .binance_smart_chain, .binance_smart_chain_testnet, .heco, .heco_testnet, .custom, .fantom, .fantom_testnet, .avalanche, .avalanche_testnet, .polygon, .mumbai_testnet, .optimistic, .cronosTestnet, .arbitrum, .palm, .palmTestnet, .klaytnCypress, .klaytnBaobabTestnet, .ioTeX, .ioTeXTestnet, .optimismGoerli, .arbitrumGoerli, .cronosMainnet, .tomb_chain, .metis:
            return true
        }
    }

    func getEtherscanURLForGeneralTransactionHistory(for address: AlphaWallet.Address, startBlock: Int?) -> URL? {
         etherscanURLForGeneralTransactionHistory.flatMap {
             let apiKeyParameter: String
             if let apiKey = etherscanApiKey {
                 apiKeyParameter = "&apikey=\(apiKey)"
             } else {
                 apiKeyParameter = ""
             }
             let url = $0.appendingQueryString("address=\(address.eip55String)\(apiKeyParameter)")
             if let startBlock = startBlock {
                 return url?.appendingQueryString("startblock=\(startBlock)")
             } else {
                 return url
             }
         }
    }

    func getEtherscanURLForTokenTransactionHistory(for address: AlphaWallet.Address, startBlock: Int?) -> URL? {
        etherscanURLForTokenTransactionHistory.flatMap {
            let apiKeyParameter: String
            if let apiKey = etherscanApiKey {
                apiKeyParameter = "&apikey=\(apiKey)"
            } else {
                apiKeyParameter = ""
            }
            let url = $0.appendingQueryString("address=\(address.eip55String)\(apiKeyParameter)")
            if let startBlock = startBlock {
                return url?.appendingQueryString("startblock=\(startBlock)")
            } else {
                return url
            }
        }
    }

    func getEtherscanURLForERC721TransactionHistory(for address: AlphaWallet.Address, startBlock: Int?) -> URL? {
        etherscanURLForERC721TransactionHistory.flatMap {
            let apiKeyParameter: String
            if let apiKey = etherscanApiKey {
                apiKeyParameter = "&apikey=\(apiKey)"
            } else {
                apiKeyParameter = ""
            }
            let url = $0.appendingQueryString("address=\(address.eip55String)\(apiKeyParameter)")
            if let startBlock = startBlock {
                return url?.appendingQueryString("startblock=\(startBlock)")
            } else {
                return url
            }
        }
    }

    //Can't use https://blockscout.com/poa/dai/address/ even though it ultimately redirects there because blockscout (tested on 20190620), blockscout.com is only able to show that URL after the address has been searched (with the ?q= URL)
    public func etherscanContractDetailsWebPageURL(for address: AlphaWallet.Address) -> URL? {
        switch self {
        case .klaytnCypress, .klaytnBaobabTestnet, .ioTeX, .ioTeXTestnet:
            return etherscanWebpageRoot?.appendingPathComponent("account").appendingPathComponent(address.eip55String)
        case .main, .xDai, .goerli, .poa, .classic, .callisto, .artis_sigma1, .artis_tau1, .binance_smart_chain, .binance_smart_chain_testnet, .custom, .heco, .heco_testnet, .fantom, .fantom_testnet, .avalanche, .avalanche_testnet, .polygon, .mumbai_testnet, .optimistic, .cronosTestnet, .arbitrum, .palm, .palmTestnet, .optimismGoerli, .arbitrumGoerli, .cronosMainnet, .tomb_chain, .metis:
            switch etherscanCompatibleType {
            case .etherscan:
                return etherscanWebpageRoot?.appendingPathComponent("address").appendingPathComponent(address.eip55String)
            case .blockscout:
                return etherscanWebpageRoot?.appendingPathComponent("search").appendingQueryString("q=\(address.eip55String)")
            case .unknown:
                return nil
            }
        }
    }

    //We assume that only Etherscan supports this and only for Ethereum mainnet: The token page instead of contract page
    //TODO check if other Etherscan networks can support this
    //TODO check if Blockscout can support this
    public func etherscanTokenDetailsWebPageURL(for address: AlphaWallet.Address) -> URL? {
        switch self {
        case .main, .klaytnCypress, .klaytnBaobabTestnet, .ioTeX, .ioTeXTestnet, .avalanche, .avalanche_testnet:
            return etherscanWebpageRoot?.appendingPathComponent("token").appendingPathComponent(address.eip55String)
        case .xDai, .goerli, .poa, .classic, .callisto, .artis_sigma1, .artis_tau1, .binance_smart_chain, .binance_smart_chain_testnet, .custom, .heco, .heco_testnet, .fantom, .fantom_testnet, .avalanche, .avalanche_testnet, .polygon, .mumbai_testnet, .optimistic, .cronosTestnet, .arbitrum, .palm, .palmTestnet, .optimismGoerli, .arbitrumGoerli, .cronosMainnet, .tomb_chain, .metis:
            return etherscanContractDetailsWebPageURL(for: address)
        }
    }

    public var symbol: String {
        switch self {
        case .main: return "ETH"
        case .classic: return "ETC"
        case .callisto: return "CLO"
        case .poa: return "POA"
        case .xDai: return "xDai"
        case .goerli: return "ETH"
        case .artis_sigma1, .artis_tau1: return "ATS"
        case .binance_smart_chain, .binance_smart_chain_testnet: return "BNB"
        case .heco, .heco_testnet: return "HT"
        case .custom(let custom): return custom.symbol ?? "ETH"
        case .fantom, .fantom_testnet: return "FTM"
        case .avalanche, .avalanche_testnet: return "AVAX"
        case .polygon, .mumbai_testnet: return "MATIC"
        case .optimistic: return "ETH"
        case .cronosMainnet: return "CRO"
        case .cronosTestnet: return "tCRO"
        case .arbitrum: return "AETH"
        case .palm: return "PALM"
        case .palmTestnet: return "PALM"
        case .klaytnCypress, .klaytnBaobabTestnet: return "KLAY"
        case .ioTeX, .ioTeXTestnet: return "ioTeX"
        case .optimismGoerli: return "ETH"
        case .arbitrumGoerli: return "AGOR"
        case .tomb_chain: return "TOMB"
        case .metis: return "METIS"
        }
    }
    
    #warning("need more info")
    public var cryptoCurrencyName: String {
        switch self {
        case .main, .classic, .callisto, .poa, .goerli, .optimistic: return "Ether"
        case .xDai: return "xDai"
        case .binance_smart_chain, .binance_smart_chain_testnet: return "BNB"
        case .artis_sigma1, .artis_tau1: return "ATS"
        case .heco, .heco_testnet: return "HT"
        case .fantom, .fantom_testnet: return "FTM"
        case .avalanche, .avalanche_testnet: return "AVAX"
        case .polygon, .mumbai_testnet: return "MATIC"
        case .cronosMainnet: return "CRO"
        case .cronosTestnet: return "tCRO"
        case .custom(let custom): return custom.nativeCryptoTokenName ?? "Ether"
        case .arbitrum: return "AETH"
        case .palm: return "PALM"
        case .palmTestnet: return "PALM"
        case .klaytnCypress, .klaytnBaobabTestnet: return "KLAY"
        case .ioTeX, .ioTeXTestnet: return "ioTeX"
        case .optimismGoerli: return "ETH"
        case .arbitrumGoerli: return "AGOR"
        case .tomb_chain: return "TOMB"
        case .metis: return "METIS"//MetisDAO
        }
    }

    public var decimals: Int {
        return 18
    }

    public var magicLinkPrefix: URL {
        let urlString = "https://\(magicLinkHost)/"
        return URL(string: urlString)!
    }
    #warning("need more info")
    public var magicLinkHost: String {
        switch self {
        case .main: return Constants.mainnetMagicLinkHost
        case .poa: return Constants.poaMagicLinkHost
        case .classic: return Constants.classicMagicLinkHost
        case .callisto: return Constants.callistoMagicLinkHost
        case .goerli: return Constants.goerliMagicLinkHost
        case .xDai: return Constants.xDaiMagicLinkHost
        case .artis_sigma1: return Constants.artisSigma1MagicLinkHost
        case .artis_tau1: return Constants.artisTau1MagicLinkHost
        case .binance_smart_chain: return Constants.binanceMagicLinkHost
        case .binance_smart_chain_testnet: return Constants.binanceTestMagicLinkHost
        case .custom: return Constants.customMagicLinkHost
        case .heco: return Constants.hecoMagicLinkHost
        case .heco_testnet: return Constants.hecoTestMagicLinkHost
        case .fantom: return Constants.fantomMagicLinkHost
        case .fantom_testnet: return Constants.fantomTestMagicLinkHost
        case .avalanche: return Constants.avalancheMagicLinkHost
        case .avalanche_testnet: return Constants.avalancheTestMagicLinkHost
        case .polygon: return Constants.maticMagicLinkHost
        case .mumbai_testnet: return Constants.mumbaiTestMagicLinkHost
        case .optimistic: return Constants.optimisticMagicLinkHost
        case .cronosMainnet: return Constants.cronosMagicLinkHost
        case .cronosTestnet: return Constants.cronosTestMagicLinkHost
        case .arbitrum: return Constants.arbitrumMagicLinkHost
        case .palm: return Constants.palmMagicLinkHost
        case .palmTestnet: return Constants.palmTestnetMagicLinkHost
        case .klaytnCypress: return Constants.klaytnCypressMagicLinkHost
        case .klaytnBaobabTestnet: return Constants.klaytnBaobabTestnetMagicLinkHost
        case .ioTeX: return Constants.ioTeXMagicLinkHost
        case .ioTeXTestnet: return Constants.ioTeXTestnetMagicLinkHost
        case .optimismGoerli: return Constants.optimismGoerliMagicLinkHost
        case .arbitrumGoerli: return Constants.arbitrumGoerliMagicLinkHost
        case .tomb_chain: return Constants.tombChainLinkHost
        case .metis: return Constants.tombChainLinkHost
        }
    }

    public var rpcURL: URL {
        let urlString: String = {
            switch self {
            case .main: return "https://rpc.ankr.com/eth"
            case .classic: return "https://www.ethercluster.com/etc"
            case .callisto: return "https://explorer.callisto.network/api/eth-rpc"
            case .poa: return "https://core.poa.network"
            case .goerli: return "https://goerli.infura.io/v3/\(Constants.Credentials.infuraKey)"
            //https://rpc.ankr.com/gnosis handles batching and errors differently from other RPC nodes
            // if there's an error, the `id` field is null (unlike others)
            // if it's a batched request of N requests and there's an error, 1 error is returned instead of N array and the `id` field in the error is null (unlike others)
            case .xDai: return "https://rpc.ankr.com/gnosis"
            case .artis_sigma1: return "https://rpc.sigma1.artis.network"
            case .artis_tau1: return "https://rpc.tau1.artis.network"
            case .binance_smart_chain: return "https://bsc-dataseed.binance.org"
            case .binance_smart_chain_testnet: return "https://data-seed-prebsc-1-s1.binance.org:8545"
            case .heco: return "https://http-mainnet.hecochain.com"
            case .heco_testnet: return "https://http-testnet.hecochain.com"
            case .custom(let custom): return custom.rpcEndpoint
            case .fantom: return "https://rpc.ankr.com/fantom"
            case .fantom_testnet: return "https://rpc.ankr.com/fantom_testnet"
            case .avalanche: return "https://api.avax.network/ext/bc/C/rpc"
            case .avalanche_testnet: return "https://api.avax-test.network/ext/bc/C/rpc"
            case .polygon: return "https://polygon-rpc.com"
            case .mumbai_testnet: return "https://rpc.ankr.com/polygon_mumbai"
            case .optimistic: return "https://rpc.ankr.com/optimism"
            case .cronosMainnet: return "https://evm.cronos.org"
            case .cronosTestnet: return "https://cronos-testnet.crypto.org:8545"
            case .arbitrum: return "https://rpc.ankr.com/arbitrum"
            case .palm: return "https://palm-mainnet.infura.io/v3/\(Constants.Credentials.infuraKey)"
            case .palmTestnet: return "https://palm-testnet.infura.io/v3/\(Constants.Credentials.infuraKey)"
            case .klaytnCypress:
                let basicAuth = Constants.Credentials.klaytnRpcNodeKeyBasicAuth
                if basicAuth.isEmpty {
                    return "https://public-node-api.klaytnapi.com/v1/cypress"
                } else {
                    return "https://node-api.klaytnapi.com/v1/klaytn"
                }
            case .klaytnBaobabTestnet:
                let basicAuth = Constants.Credentials.klaytnRpcNodeKeyBasicAuth
                if basicAuth.isEmpty {
                    return "https://api.baobab.klaytn.net:8651"
                } else {
                    return "https://node-api.klaytnapi.com/v1/klaytn"
                }
            case .ioTeX: return "https://babel-api.mainnet.iotex.io"
            case .ioTeXTestnet: return "https://babel-api.testnet.iotex.io"
            case .optimismGoerli: return "https://rpc.ankr.com/optimism_testnet"
            case .arbitrumGoerli: return "https://optimism-goerli.infura.io/v3/\(Constants.Credentials.infuraKey)"
            case .tomb_chain: return "https://rpc.tombchain.com"
            case .metis: return "https://andromeda.metis.io/?owner=1088"
            }
        }()
        return URL(string: urlString)!
    }

    //Main reason for this is we can't use KAS nodes for Klaytn mainnet and testnet as we can't/didn't also inject the Basic Auth
    //TODO fix it so Klaytn KAS Basic Auth is injected to web3 browser. Their public node are always rate limited
    var web3InjectedRpcURL: URL {
        switch serverWithEnhancedSupport {
        case .main, .xDai, .polygon, .binance_smart_chain, .heco, .rinkeby, .arbitrum, nil:
            return rpcURL
        case .klaytnCypress:
            return URL(string: "https://public-node-api.klaytnapi.com/v1/cypress")!
        case .klaytnBaobabTestnet:
            return URL(string: "https://api.baobab.klaytn.net:8651")!
        }
    }

    var transactionInfoEndpoints: URL? {
        switch self {
        case .main, .goerli, .classic, .poa, .xDai, .artis_sigma1, .artis_tau1, .binance_smart_chain, .binance_smart_chain_testnet, .fantom, .polygon, .mumbai_testnet, .heco, .heco_testnet, .callisto, .optimistic, .cronosTestnet, .custom, .arbitrum, .palm, .palmTestnet, .klaytnCypress, .klaytnBaobabTestnet, .ioTeX, .ioTeXTestnet, .optimismGoerli, .optimismGoerli, .arbitrumGoerli, .cronosMainnet, .avalanche, .avalanche_testnet, .tomb_chain, .metis:
            return etherscanApiRoot
        case .fantom_testnet: return URL(string: "https://explorer.testnet.fantom.network/tx/")
        }
    }
    #warning("need more info")
    var networkRequestsQueuePriority: Operation.QueuePriority {
        switch self {
        case .main, .polygon, .klaytnCypress, .klaytnBaobabTestnet: return .normal
        case .xDai, .poa, .classic, .callisto, .goerli, .artis_sigma1, .artis_tau1, .binance_smart_chain, .binance_smart_chain_testnet, .custom, .heco, .heco_testnet, .fantom, .fantom_testnet, .avalanche, .avalanche_testnet, .mumbai_testnet, .optimistic, .cronosTestnet, .arbitrum, .palm, .palmTestnet, .ioTeX, .ioTeXTestnet, .optimismGoerli, .arbitrumGoerli, .cronosMainnet, .tomb_chain, .metis: return .low
        }
    }
    #warning("need more info")
    var transactionsSource: TransactionsSource {
        switch self {
        case .main, .classic, .callisto, .custom, .poa, .goerli, .xDai, .artis_sigma1, .binance_smart_chain, .binance_smart_chain_testnet, .artis_tau1, .heco, .heco_testnet, .fantom, .fantom_testnet, .avalanche, .avalanche_testnet, .polygon, .mumbai_testnet, .optimistic, .cronosTestnet, .arbitrum, .palm, .palmTestnet, .optimismGoerli, .arbitrumGoerli, .cronosMainnet, .tomb_chain, .metis:
            return .etherscan
        case .klaytnCypress, .klaytnBaobabTestnet:
            return .etherscan
        case .ioTeX, .ioTeXTestnet:
            return .covalent
        }
    }

    public init(chainID: Int) {
        //TODO defaulting to .main is bad
        self = Self.availableServers.first { $0.chainID == chainID } ?? .main
    }

    public init?(chainIdOptional chainID: Int) {
        guard let server = Self.availableServers.first(where: { $0.chainID == chainID }) else {
            return nil
        }
        self = server
    }

    public init?(withMagicLinkHost magicLinkHost: String) {
        var server: RPCServer?
        //Special case to support legacy host name
        if magicLinkHost == Constants.legacyMagicLinkHost {
            server = .main
        } else {
            server = Self.availableServers.first { $0.magicLinkHost == magicLinkHost }
        }
        guard let createdServer = server else { return nil }
        self = createdServer
    }

    public init?(withMagicLink url: URL) {
        guard let host = url.host, let server = RPCServer(withMagicLinkHost: host) else { return nil }
        self = server
    }

    //We'll have to manually new cases here
    //Cannot be `let` as the chains can change dynamically without the app being restarted (i.e. killed). The UI can be restarted though (when switching changes)
    static public var allCases: [RPCServer] {
        return [
            .main,
            .poa,
            .classic,
            .xDai,
            .goerli,
            .artis_sigma1,
            .artis_tau1,
            .binance_smart_chain_testnet,
            .binance_smart_chain,
            .heco,
            .heco_testnet,
            .fantom,
            .fantom_testnet,
            .avalanche,
            .avalanche_testnet,
            .polygon,
            .callisto,
            .mumbai_testnet,
            .optimistic,
            .cronosMainnet,
            .cronosTestnet,
            .arbitrum,
            .klaytnCypress,
            .klaytnBaobabTestnet,
            .palm,
            .palmTestnet,
            //.ioTeX, //TODO: Disabled as non in Phase 1 anymore, need to take a look on transactions, native balances
            //.ioTeXTestnet
            .optimismGoerli,
            .arbitrumGoerli,
            .tomb_chain,
            .metis
        ]
    }

    public static var availableServers: [RPCServer] {
        allCases + RPCServer.customServers
    }

    private static func convertJsonToCustomRpcs(_ json: String?) -> [CustomRPC] {
        if let json = json {
            let data = json.data(using: .utf8)
            if let servers = try? JSONDecoder().decode([CustomRPC].self, from: data!) {
                return servers
            } else {
                return .init()
            }
        } else {
            return .init()
        }
    }
    #warning("need more info")
    var maximumBlockRangeForEvents: UInt64? {
        switch self {
        case .binance_smart_chain, .binance_smart_chain_testnet, .heco, .heco_testnet:
            //These do not allow range more than 5000
            return 4990
        case .optimistic:
            //These not allow range more than 10000
            return 9999
        case .polygon:
            //These not allow range more than 3500
            return 3499
        case .mumbai_testnet:
            //These not allow range more than 3500
            return 3499
        case .cronosTestnet, .arbitrum:
            //These not allow range more than 100000
            return 99990
        case .xDai:
            return 3000
        case .fantom_testnet:
            return 3000
        case .main, .poa, .classic, .callisto, .goerli, .artis_sigma1, .artis_tau1, .fantom, .custom, .palm, .palmTestnet, .optimismGoerli, .arbitrumGoerli, .tomb_chain, .metis:
            return nil
        case .klaytnCypress, .klaytnBaobabTestnet, .ioTeX, .ioTeXTestnet:
            //These not allow range more than 10,000
            return 9999
        case .cronosMainnet:
            return 1999
        case .avalanche, .avalanche_testnet:
            //These not allow range more than 2048
            return 2047
        }
    }
    #warning("need more info")
    public var displayOrderPriority: Int {
        switch self {
        case .fantom: return 1
        case .tomb_chain: return 2
        case .main: return 3
        case .binance_smart_chain: return 4
        case .polygon: return 5
        case .avalanche: return 6
        case .arbitrum: return 7
        case .xDai: return 8
        case .classic: return 9
        case .poa: return 10
        case .callisto: return 11
        case .goerli: return 16
        case .artis_sigma1: return 246529
        case .artis_tau1: return 246785
        case .binance_smart_chain_testnet: return 13
        case .custom(let custom): return 300000 + custom.chainID
        case .heco: return 14
        case .heco_testnet: return 15
        case .fantom_testnet: return 17
        case .avalanche_testnet: return 19
        case .polygon: return 20
        case .mumbai_testnet: return 21
        case .optimistic: return 22
        case .cronosTestnet: return 24
        case .arbitrum: return 25
        case .palm: return 27
        case .palmTestnet: return 28
        case .klaytnCypress: return 29
        case .klaytnBaobabTestnet: return 30
        case .ioTeX: return 33
        case .ioTeXTestnet: return 34
        case .optimismGoerli: return 36
        case .arbitrumGoerli: return 37
        case .cronosMainnet: return 38
        case .metis: return 39
        }
    }
    public var explorerName: String {
        switch self {
        case .main, .goerli, .optimismGoerli, .arbitrumGoerli: return "Etherscan"
        case .classic, .poa, .custom, .callisto, .binance_smart_chain, .binance_smart_chain_testnet, .heco, .heco_testnet, .fantom, .fantom_testnet, .avalanche, .avalanche_testnet, .polygon, .mumbai_testnet, .optimistic, .arbitrum, .palm, .palmTestnet, .klaytnCypress, .klaytnBaobabTestnet, .ioTeX, .ioTeXTestnet, .optimismGoerli, .tomb_chain: return "\(name) Explorer"
        case .xDai: return "Blockscout"
        case .artis_sigma1, .artis_tau1: return "ARTIS"
        case .cronosMainnet, .cronosTestnet: return "Cronoscan"
        case .metis: return "Andromeda Explorer"
        }
    }
    #warning("need more info")
    //Implementation: Almost every chain should return nil here
    public var serverWithEnhancedSupport: RPCServerWithEnhancedSupport? {
        switch self {
        case .main: return .main
        case .xDai: return .xDai
        case .polygon: return .polygon
        case .binance_smart_chain: return .binance_smart_chain
        case .heco: return .heco
        case .arbitrum: return .arbitrum
        case .klaytnCypress: return .klaytnCypress
        case .klaytnBaobabTestnet: return .klaytnBaobabTestnet
        case .main, .goerli, .artis_sigma1, .artis_tau1, .custom, .poa, .callisto, .xDai, .classic, .binance_smart_chain_testnet, .heco_testnet, .fantom, .fantom_testnet, .avalanche, .avalanche_testnet, .mumbai_testnet, .optimistic, .cronosTestnet, .palm, .palmTestnet, .ioTeX, .ioTeXTestnet, .optimismGoerli, .arbitrumGoerli, .cronosMainnet, .tomb_chain, .metis: return nil
        }
    }
    #warning("need more info")
    var coinGeckoPlatform: String? {
        switch self {
        case .main: return "ethereum"
        case .classic: return "ethereum-classic"
        case .xDai: return "xdai"
        case .binance_smart_chain: return "binance-smart-chain"
        case .avalanche: return "avalanche"
        case .polygon: return "polygon-pos"
        case .fantom: return "fantom"
        case .arbitrum: return "arbitrum-one"
        case .klaytnCypress, .klaytnBaobabTestnet: return "klay-token"
        case .cronosMainnet: return "cronos"
        case .tomb_chain: return "tomb"
        case .poa, .callisto, .goerli, .artis_sigma1, .artis_tau1, .binance_smart_chain_testnet, .heco, .heco_testnet, .fantom_testnet, .avalanche_testnet, .mumbai_testnet, .custom, .optimistic, .cronosTestnet, .palm, .palmTestnet, .ioTeX, .ioTeXTestnet, .optimismGoerli, .arbitrumGoerli, .metis: return nil
        }
    }
    #warning("need more info")
    var coinbasePlatform: String? {
        switch self {
        case .main: return "ethereum"
        case .fantom, .avalanche, .xDai, .classic, .arbitrum, .polygon, .binance_smart_chain, .klaytnCypress, .klaytnBaobabTestnet, .poa, .callisto, .goerli, .artis_sigma1, .artis_tau1, .binance_smart_chain_testnet, .heco, .heco_testnet, .fantom_testnet, .avalanche_testnet, .mumbai_testnet, .custom, .optimistic, .cronosTestnet, .palm, .palmTestnet, .ioTeX, .ioTeXTestnet, .optimismGoerli, .arbitrumGoerli, .cronosMainnet, .tomb_chain, .metis: return nil
        }
    }
    #warning("need more info")
    var shouldExcludeZeroGasPrice: Bool {
        switch self {
        case .klaytnCypress, .klaytnBaobabTestnet: return true
        case .binance_smart_chain, .binance_smart_chain_testnet, .heco, .heco_testnet, .optimistic, .polygon, .mumbai_testnet, .cronosTestnet, .arbitrum, .main, .poa, .classic, .callisto, .goerli, .artis_sigma1, .artis_tau1, .fantom, .fantom_testnet, .avalanche, .avalanche_testnet, .custom, .palm, .palmTestnet, .ioTeX, .ioTeXTestnet, .xDai, .optimismGoerli, .arbitrumGoerli, .cronosMainnet, .tomb_chain, .metis: return false
        }
    }
    #warning("need more info")
    //These limits are empirically determined to:
    // A. fit within the node's limits, and
    // B. and be fast enough to return
    var rpcNodeBatchSupport: RpcNodeBatchSupport {
        switch self {
        case .klaytnCypress, .klaytnBaobabTestnet: return .noBatching
        case .xDai: return .batch(1000)
        case .cronosMainnet: return .batch(5)
        //Infura's. Can do more, but way too slow
        case .main, .goerli, .polygon, .mumbai_testnet, .arbitrum, .arbitrumGoerli, .palm, .palmTestnet, .optimistic, .optimismGoerli, .tomb_chain, .metis: return .batch(100)
        case .classic: return .batch(128)
        case .callisto, .poa: return .batch(1000)
        case .artis_sigma1, .artis_tau1: return .batch(100)
        case .binance_smart_chain, .binance_smart_chain_testnet: return .batch(100)
        case .heco, .heco_testnet: return .batch(1000)
        case .fantom:  return .batch(1000)
        case .fantom_testnet: return .batch(1000)
        case .ioTeX, .ioTeXTestnet: return .batch(200)
        case .cronosTestnet, .avalanche, .avalanche_testnet, .custom: return .batch(32)
        }
    }

    var conflictedServer: RPCServer? {
        for each in RPCServer.availableServers {
            if let index = RPCServer.allCases.index(where: { each == $0 }), each.isCustom {
                return RPCServer.allCases[index]
            } else {
                continue
            }
        }

        return nil
    }
}
// swiftlint:enable type_body_length

extension RPCServer: Codable {
    private enum Keys: String, CodingKey {
        case chainId
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let chainId = try container.decode(Int.self, forKey: .chainId)
        self = .init(chainID: chainId)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encode(chainID, forKey: .chainId)
    }
}

extension URL {
    //Much better to use URLComponents, but this is much simpler for our use. This probably doesn't percent-escape probably, but we shouldn't need it for the URLs we access here
	func appendingQueryString(_ queryString: String) -> URL? {
        let urlString = absoluteString
        if urlString.contains("?") {
            return URL(string: "\(urlString)&\(queryString)")
        } else {
            return URL(string: "\(urlString)?\(queryString)")
        }
	}
}
