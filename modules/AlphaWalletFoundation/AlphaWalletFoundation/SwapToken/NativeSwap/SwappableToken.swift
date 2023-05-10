// Copyright © 2022 Stormbird PTE. LTD.

import Foundation

public struct SwappableToken: Decodable, Equatable {
    private enum Keys: String, CodingKey {
        case chainId
        case address
        case symbol
        case decimals
        case name
        case priceUSD
        case coinKey
        case logoURI
    }

    private struct ParsingError: Error {
        let fieldName: Keys
    }

    let address: AlphaWallet.Address
    let server: RPCServer
    let symbol: String?
    let decimals: Int?
    let name, priceUSD, coinKey: String?
    let logoURI: String?

    init(address: AlphaWallet.Address, server: RPCServer, symbol: String? = nil, decimals: Int? = nil, name: String? = nil, priceUSD: String? = nil, coinKey: String? = nil, logoURI: String? = nil) {
        self.address = address
        self.server = server
        self.symbol = symbol
        self.decimals = decimals
        self.name = name
        self.priceUSD = priceUSD
        self.coinKey = coinKey
        self.logoURI = logoURI
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)

        let addressString = try container.decode(String.self, forKey: .address)
        let chainId = try container.decode(Int.self, forKey: .chainId)

        address  = try AlphaWallet.Address(string: addressString) ?? { throw ParsingError(fieldName: .address) }()
        server   = RPCServer(chainID: chainId)
        symbol   = try container.decode(String.self, forKey: .symbol)
        decimals = try container.decode(Int.self, forKey: .decimals)
        name     = try container.decode(String.self, forKey: .name)
        priceUSD = try container.decode(String.self, forKey: .priceUSD)
        coinKey  = try container.decode(String.self, forKey: .coinKey)
        logoURI  = try container.decode(String.self, forKey: .logoURI)
    }
        
    public func getAppToken() -> Token? {
        guard let name = name, !name.isEmpty, let symbol = symbol, !symbol.isEmpty, let decimals = decimals else { return nil }
        return Token(contract: address, server: server, name: name, symbol: symbol, decimals: decimals, shouldDisplay: true)
    }
    
}
