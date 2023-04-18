//
//  TokenAPI.swift
//  Lif3Wallet
//
//  Created by Amrit Duwal on 3/27/20.
//  Copyright © 2022 . All rights reserved.
//

import Foundation

protocol TokenAPI {
    func getToken(name: String, success: @escaping (TokenParent) -> (), failure: @escaping (Error) -> ())
}

extension TokenAPI {
    
    func getToken(name: String, success: @escaping (TokenParent) -> (), failure: @escaping (Error) -> ()){
        let urlSession = URLSession.shared
        let request = EndPoint.getTokens(name: name).request()
        urlSession.dataTask(request: request, success:success, failure: failure)
    }
    
}
