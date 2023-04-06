//
//  Auth.swift
//  DoCo22
//
//  Created by EKbana MacMini 2018 on 2/17/20.
//  Copyright © 2020 ekbana. All rights reserved.
//

import Foundation

struct DeploymentMode: OptionSet {
    typealias RawValue = Int
    
    static func ==(lhs: DeploymentMode, rhs: DeploymentMode) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    var rawValue: DeploymentMode.RawValue
    static let dev: DeploymentMode = DeploymentMode(rawValue: 0)
    static let uat: DeploymentMode = DeploymentMode(rawValue: 1)
    static let live: DeploymentMode = DeploymentMode(rawValue: 2)
}

struct Lif3WalletConfiguration {
    let clientId: String
    let scope: String
    let clientSecret: String
    let apiKey: String
    let scheme: String
    let host: String
    let apiPath: String
    var base: String {
        return scheme + "://" + host
    }
    var baseURL: String {
        return base + apiPath
    }
    let domain: String
    let googleApiKey: String
    let contactEmail: String
    let googleClientId: String
    let lineChannelID: String
    
    static var conf: Lif3WalletConfiguration {
        switch deploymentMode {
        case .uat:
            return Lif3WalletConfiguration(
                clientId: "2",
                scope: "",
                clientSecret: "ajjWqmKsXmUheMJCbENABZagpfTPkvBpezFsZ4Yd",
                apiKey: "xqyxurnW95a95rmeTxrLZW2YM7K96CsnbwAPWPBUv4paEm4YXYT8AHdNkSDA2kEhw9pvXwqmWUg3p6hW",
                scheme: "https",
                host: "https://assets.lif3.com",
                apiPath: "",
                domain: "",
                googleApiKey: "",
                contactEmail: "",
                googleClientId: "",
                lineChannelID: "")
        case .live:
            return Lif3WalletConfiguration(
                clientId: "2",
                scope: "",
                clientSecret: "ajjWqmKsXmUheMJCbENABZagpfTPkvBpezFsZ4Yd",
                apiKey: "sN3zPky31zoOiQlKT5fmK9cpLNcRLXukaU9CYOI6GDTOEq4HnCufliyEoinhIHMxmWwbUj5CnaMc9v5a",
                scheme: "https",
                host: "assets.lif3.com",
                apiPath: "",
                domain: "automobuy-dev",
                googleApiKey: "",
                contactEmail: "info@doco22.com",
                googleClientId: "144742788734-h6o8d4a4j7n2i3apfhn829mmdcvsj9f7.apps.googleusercontent.com",
                lineChannelID: "1655234542")
        default:
            return Lif3WalletConfiguration(
                clientId: "2",
                scope: "",
                clientSecret: "ajjWqmKsXmUheMJCbENABZagpfTPkvBpezFsZ4Yd",
                apiKey: "xqyxurnW95a95rmeTxrLZW2YM7K96CsnbwAPWPBUv4paEm4YXYT8AHdNkSDA2kEhw9pvXwqmWUg3p6hW",
                scheme: "https",
                host: "assets.lif3.com",
                apiPath: "",
                domain: "automobuy-dev",
                googleApiKey: "AIzaSyD3ijt_HctxQBDPtd32vLcaA-bmBZzxkzU",
                contactEmail: "info@doco22.com",
                googleClientId: "144742788734-lq0gh0csvdkss1o96h3bvlpof9olelfm.apps.googleusercontent.com",
                lineChannelID: "1655256098")
        }
    }
}
