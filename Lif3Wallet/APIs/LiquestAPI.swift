//
//  LiquestAPI.swift
//  Lif3Wallet
//
//  Created by Amrit Duwal on 3/27/20.
//  Copyright © 2022 . All rights reserved.
//

import Foundation

protocol LiquestAPI {
    func getLiQuestConnections(fromChain: String, success: @escaping (LiQuest) -> (), failure: @escaping (Error) -> ())
}

extension LiquestAPI {
    func getLiQuestConnections(fromChain: String, success: @escaping (LiQuest) -> (), failure: @escaping (Error) -> ()){
        let urlSession = URLSession.shared
        var param =  [String: Any]()
        param = [
            "fromChain": fromChain
        ]
        let request = EndPoint.getLiQuest.request(body: param)
        urlSession.dataTask(request: request, success:success, failure: failure)
    }
}
