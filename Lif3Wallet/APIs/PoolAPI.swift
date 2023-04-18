//
//  PoolAPI.swift
//  Lif3Wallet
//
//  Created by Amrit Duwal on 3/27/20.
//  Copyright © 2022 . All rights reserved.
//

import Foundation

protocol PoolAPI {
    func getPool(name: String, success: @escaping (PoolParent) -> (), failure: @escaping (Error) -> ())
}

extension PoolAPI {
    func getPool(name: String, success: @escaping (PoolParent) -> (), failure: @escaping (Error) -> ()){
        let urlSession = URLSession.shared
        let request = EndPoint.pool(name: name).request()
        urlSession.dataTask(request: request, success:success, failure: failure)
    }
}
