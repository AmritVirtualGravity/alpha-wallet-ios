//
//  API.swift
//
//
//  Created by   2018 on 2/19/20.
//  Copyright © 2020 . All rights reserved.
//

import Foundation

struct AppRequest {
    let request: URLRequest
    let endPoint: EndPoint
    
    func cache<T: Codable>(data: T) {
        if endPoint.shouldCache {
            GlobalConstants.KeyValues.apiCache(key: getKey(url: request.url!), data: data)
        }
    }
    
    func cached<T: Codable>() -> T? {
        if endPoint.shouldCache {
            return GlobalConstants.KeyValues.apiCache(key: getKey(url: request.url!))
        }
        return nil
    }
    
    init(request: URLRequest, endPoint: EndPoint) {
        self.request = request
        self.endPoint = endPoint
    }
    
    private func getKey(url: URL) -> String {
        switch endPoint {
//        case .places: break
        default:
            return url.absoluteString
        }
        let key = "\(url.scheme!)://\(url.host!)"
        if url.pathComponents.isEmpty {
            return key
        } else {
            return key + "/" + url.pathComponents.dropFirst().joined(separator: "/")
        }
    }
    
}

public enum EndPoint {
    case login
    case pool(name: String)
    case getTokens(name: String)
    
    private var path: String {
        switch self {
//        case .login: return "users/login-pin"
        case .login: return "users/mobile/signup"
        case .pool(let name): return "wallet/staking/chain/\(name).json"
        case .getTokens(let name): return "wallet/staking/chain/\(name)/tokens.json"
        }
    }
    
    private var method: String {
        switch self {
        case .login: return "POST"
//        case .cancelOrder, .editAddress: return "PUT"
////        case .withdraw:
////            return "DELETE"
//        case .deleteAddress: return "DELETE"
        default: return "GET"
        }
    }
    
    fileprivate var shouldCache: Bool {
        switch self {
//        case .appInfo:  return true
        default:  return false
        }
    }
    
    private var authentication: Bool {
        switch self {
        case .login: return false
        default: return true
        }
    }
    
    func request(urlString: String, body: [String: Any]? = nil) -> AppRequest {
        let url = URL(string: urlString.replacingOccurrences(of: " ", with: "%20"))!
        debugPrint(url)
        var request = URLRequest(url: url)
        request.httpMethod = method
        if method == "POST" || method == "DELETE" || method == "PUT" {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let body = body {
                request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            }
        }
        if authentication {
//            request.setValue(GlobalConstants.KeyValues.user?.authToken ?? "" , forHTTPHeaderField: "authToken")
        }

//        request.setValue(Localize.currentLanguage(), forHTTPHeaderField: "Accept-Language")
//        if let token = GlobalConstanst.KeyValues.accessToken?.token {
//            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        }
        CurrentHeaderBodyParameter.body    = body
        CurrentHeaderBodyParameter.request = request
        return AppRequest(request: request, endPoint: self)
    }
    
    func request(body: [String: Any]? = nil) -> AppRequest {
        let urlString = Lif3WalletConfiguration.conf.baseURL + "/" + path
        return request(urlString: urlString, body: body)
    }
    
    private func getURL(query: [String: String]? = nil) -> URL {
        var components    = URLComponents()
        components.scheme = Lif3WalletConfiguration.conf.scheme
        components.host   = Lif3WalletConfiguration.conf.host
        components.path   = Lif3WalletConfiguration.conf.apiPath + "/" + path
        components.queryItems = query?.map({
            return URLQueryItem(name: $0, value: $1)
        })
        return components.url!
    }
    
}
