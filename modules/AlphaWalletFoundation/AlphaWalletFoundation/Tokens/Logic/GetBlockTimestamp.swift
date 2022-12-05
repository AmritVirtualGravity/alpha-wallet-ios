// Copyright © 2020 Stormbird PTE. LTD.

import Foundation
import BigInt
import PromiseKit 
import AlphaWalletWeb3
import AlphaWalletCore
import JSONRPCKit
import APIKit

final class GetBlockTimestamp {
    private let fileName: String
    private let queue = DispatchQueue(label: "org.alphawallet.swift.getBlockTimestamp")
    private lazy var storage: Storage<[String: Date]> = .init(fileName: fileName, storage: FileStorage(fileExtension: "json"), defaultValue: [:])
    private var inFlightPromises: [String: Promise<Date>] = [:]
    private let analytics: AnalyticsLogger

    init(fileName: String = "blockTimestampStorage", analytics: AnalyticsLogger) {
        self.fileName = fileName
        self.analytics = analytics
    }

    func getBlockTimestamp(for blockNumber: BigUInt, server: RPCServer) -> Promise<Date> {
        firstly {
            .value(blockNumber)
        }.then(on: queue, { [weak self, queue, storage, analytics] blockNumber -> Promise<Date> in
            let key = "\(blockNumber)-\(server)"
            if let value = storage.value[key] {
                return .value(value)
            }

            if let promise = self?.inFlightPromises[key] {
                return promise
            } else {
                let request = EtherServiceRequest(server: server, batch: BatchFactory().create(BlockByNumberRequest(number: blockNumber)))
                let promise = firstly {
                    APIKitSession.send(request, server: server, analytics: analytics)
                }.map(on: queue, {
                    $0.timestamp
                }).ensure(on: queue, {
                    self?.inFlightPromises[key] = .none
                }).get(on: queue, { date in
                    storage.value[key] = date
                })

                self?.inFlightPromises[key] = promise

                return promise
            }
        })
    }
}

