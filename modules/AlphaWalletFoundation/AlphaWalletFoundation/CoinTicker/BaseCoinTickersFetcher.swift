//
//  BaseCoinTickersFetcher.swift
//  Alamofire
//
//  Created by Vladyslav Shepitko on 16.09.2022.
//

import Foundation
import Combine
import AlphaWalletCore

public class BaseCoinTickersFetcher {
    private let pricesCacheLifetime: TimeInterval = 60 * 60
    private let dayChartHistoryCacheLifetime: TimeInterval = 60 * 60
    private let storage: CoinTickersStorage & ChartHistoryStorage & TickerIdsStorage
    private let networkProvider: CoinTickerNetworkProviderType
    private let tickerIdsFetcher: TickerIdsFetcher
    /// Cached fetch ticker prices operations
    private var inlightPromises: AtomicDictionary<TokenMappedToTicker, AnyCancellable> = .init()
    /// Resolving ticker ids operations
    private var tickerResolvers: AtomicDictionary<TokenMappedToTicker, AnyCancellable> = .init()

    public init(networkProvider: CoinTickerNetworkProviderType, storage: CoinTickersStorage & ChartHistoryStorage & TickerIdsStorage, tickerIdsFetcher: TickerIdsFetcher) {
        self.networkProvider = networkProvider
        self.tickerIdsFetcher = tickerIdsFetcher
        self.storage = storage

        //NOTE: Remove old files with tickers, ids and price histories
        ["tickers", "tickersIds", "history"].map {
            FileStorage().fileURL(with: $0, fileExtension: "json")
        }.forEach { try? FileManager.default.removeItem(at: $0) }
    }
    
    public func cancel() {
        inlightPromises.values.values.forEach { $0.cancel() }
        inlightPromises.removeAll()
    }

    public func addOrUpdateTestsOnly(ticker: CoinTicker?, for token: TokenMappedToTicker) {
        let tickers: [AssignedCoinTickerId: CoinTicker] = ticker.flatMap { ticker in
            let tickerId = AssignedCoinTickerId(tickerId: "tickerId-\(token.contractAddress)-\(token.server.chainID)", token: token)
            return [tickerId: ticker]
        } ?? [:]

        storage.addOrUpdate(tickers: tickers)
    }

    public func fetchTickers(for tokens: [TokenMappedToTicker], force: Bool = false) {
        let targetTokensToFetchTickers = tokens.filter {
            if inlightPromises[$0] != nil {
                return false
            } else {
               return force || hasExpiredTickersLifeTimeSinceLastUpdate(for: $0)
            }
        }

        guard !targetTokensToFetchTickers.isEmpty else { return }

        //NOTE: use shared loading tickers operation for batch of tokens
        let operation = fetchBatchOfTickers(for: targetTokensToFetchTickers, currency: Currency.USD.rawValue)
            .sink(receiveCompletion: { [inlightPromises] _ in
                for token in targetTokensToFetchTickers {
                    inlightPromises.removeValue(forKey: token)
                }
            }, receiveValue: { [storage] in storage.addOrUpdate(tickers: $0) })

        for token in targetTokensToFetchTickers {
            inlightPromises[token] = operation
        }
    }

    public func resolveTikerIds(for tokens: [TokenMappedToTicker]) {
        for each in tokens {
            guard tickerResolvers[each] == nil else { continue }

            tickerResolvers[each] = tickerIdsFetcher.tickerId(for: each)
                .handleEvents(receiveCompletion: { [tickerResolvers] _ in
                    tickerResolvers.removeValue(forKey: each)
                }, receiveCancel: { [tickerResolvers] in
                    tickerResolvers.removeValue(forKey: each)
                }).sink { _ in }
        }
    }

    /// Returns cached chart history if its not expired otherwise download a new version of history, if ticker id has found
    public func fetchChartHistories(for token: TokenMappedToTicker, force: Bool, periods: [ChartHistoryPeriod]) -> AnyPublisher<[ChartHistoryPeriod: ChartHistory], Never> {
        let publishers = periods.map { fetchChartHistory(force: force, period: $0, for: token, currency: Currency.USD.rawValue) }

        return Publishers.MergeMany(publishers).collect()
            .map { $0.reorder(by: periods) }
            .map { mapped -> [ChartHistoryPeriod: ChartHistory] in
                var values: [ChartHistoryPeriod: ChartHistory] = [:]
                for each in mapped {
                    values[each.period] = each.history
                }
                return values
            }.eraseToAnyPublisher()
    }

    struct HistoryToPeriod {
        let period: ChartHistoryPeriod
        let history: ChartHistory
    }

    private func fetchChartHistory(force: Bool, period: ChartHistoryPeriod, for token: TokenMappedToTicker, currency: String) -> AnyPublisher<HistoryToPeriod, Never> {
        return tickerIdsFetcher.tickerId(for: token)
            .flatMap { [storage, networkProvider, weak self] tickerId -> AnyPublisher<HistoryToPeriod, Never> in
                guard let strongSelf = self else { return .empty() }
                guard let tickerId = tickerId.flatMap({ AssignedCoinTickerId(tickerId: $0, token: token) }) else {
                    return .just(.init(period: period, history: .empty))
                }

                if let data = storage.chartHistory(period: period, for: tickerId), !strongSelf.hasExpired(history: data, for: period), !force {
                    return .just(.init(period: period, history: data.history))
                } else {
                    return networkProvider.fetchChartHistory(for: period, tickerId: tickerId.tickerId, currency: currency)
                        .handleEvents(receiveOutput: { history in
                            storage.addOrUpdateChartHistory(history: history, period: period, for: tickerId)
                        }).replaceError(with: .empty)
                        .map { HistoryToPeriod(period: period, history: $0) }
                        .receive(on: RunLoop.main)
                        .eraseToAnyPublisher()
                }
            }.eraseToAnyPublisher()
    }

    private func hasExpiredTickersLifeTimeSinceLastUpdate(for token: TokenMappedToTicker) -> Bool {
        let key = AddressAndRPCServer(address: token.contractAddress, server: token.server)
        if let lastFetchingDate = storage.historyLastUpdatedAt(for: key), Date().timeIntervalSince(lastFetchingDate) <= pricesCacheLifetime {
            return false
        }
        return true
    }

    private func hasExpired(history mappedChartHistory: MappedChartHistory, for period: ChartHistoryPeriod) -> Bool {
        guard ReachabilityManager().isReachable else { return false }
        
        let hasCacheExpired: Bool
        switch period {
        case .day:
            let fetchDate = mappedChartHistory.fetchDate
            hasCacheExpired = Date().timeIntervalSince(fetchDate) > dayChartHistoryCacheLifetime
        case .week, .month, .threeMonth, .year:
            hasCacheExpired = false
        }
        if hasCacheExpired || mappedChartHistory.history.prices.isEmpty {
            //TODO improve by returning the cached value and returning again after refetching. Harder to do with current implement because promises only resolves once. Maybe the Promise's type should be a subscribable?
            return true
        } else {
            return false
        }
    }

    private func fetchBatchOfTickers(for tokens: [TokenMappedToTicker], currency: String) -> AnyPublisher<[AssignedCoinTickerId: CoinTicker], PromiseError> {
        let publishers = tokens.map { token in
            tickerIdsFetcher.tickerId(for: token).map { $0.flatMap { AssignedCoinTickerId(tickerId: $0, token: token) } }
        }

        return Publishers.MergeMany(publishers).collect()
            .setFailureType(to: PromiseError.self)
            .flatMap { [networkProvider] tickerIds -> AnyPublisher<[AssignedCoinTickerId: CoinTicker], PromiseError> in
                let tickerIds = tickerIds.compactMap { $0 }
                let ids = tickerIds.compactMap { $0.tickerId }
                return networkProvider.fetchTickers(for: ids, currency: currency).map { tickers in
                    var result: [AssignedCoinTickerId: CoinTicker] = [:]

                    for ticker in tickers {
                        for tickerId in tickerIds.filter({ $0.tickerId == ticker.id }) {
                            result[tickerId] = ticker
                        }
                    }
                    return result
                }.eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }
}

extension BaseCoinTickersFetcher.HistoryToPeriod: Reorderable {
    typealias OrderElement = ChartHistoryPeriod
    var orderElement: ChartHistoryPeriod { return period }
}
