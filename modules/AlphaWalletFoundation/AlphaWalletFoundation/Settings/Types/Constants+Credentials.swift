// Copyright © 2019 Stormbird PTE. LTD.
import Foundation
import AlphaWalletLogger

extension Constants {
    public enum Credentials {
        private static var cachedDevelopmentCredentials: [String: String]? = readDevelopmentCredentialsFile()

        private static func readDevelopmentCredentialsFile() -> [String: String]? {
            guard let sourceRoot = ProcessInfo.processInfo.environment["SOURCE_ROOT"] else {
                debugLog("[Credentials] No .credentials file found for development because SOURCE_ROOT is not set")
                return nil
            }
            let fileName = "\(sourceRoot)/.credentials"
            guard let fileContents = try? String(contentsOfFile: fileName) else {
                debugLog("[Credentials] No .credentials file found for development at \(fileName)")
                return nil
            }
            let lines = fileContents.components(separatedBy: .newlines)
            let keyValues: [(String, String)] = lines.compactMap { line -> (String, String)? in
                Constants.Credentials.functional.extractKeyValueCredentials(line)
            }
            let dict = Dictionary(uniqueKeysWithValues: keyValues)
            debugLog("[Credentials] Loaded .credentials file found for development with key count: \(dict.count)")
            return dict
        }

        private static func env(_ name: String) -> String? {
            if Environment.isDebug, let cachedDevelopmentCredentials = cachedDevelopmentCredentials {
                return cachedDevelopmentCredentials[name]
            } else {
                //We inject the environment variables into the app through Xcode scheme configuration (we do this so that we can pass the environment variables injected by Travis dashboard into the shell to the app). But this means the injected/forwarded variables will be an empty string if they are missing (and no longer nil)
                if let value = ProcessInfo.processInfo.environment[name], !value.isEmpty {
                    return value
                } else {
                    return nil
                }
            }
        }

        public static let analyticsKey = ""
        public static let mailChimpListSpecificKey = "df306008c71da38ba3940d8643e25362"
        public static let walletConnectProjectId = "73a6c37191ac566feabe6ef5c8e8dda7"
        static let infuraKey = env("INFURAKEY") ?? "cda4f16979b941298843c90c14dc967f"
        static let etherscanKey = env("ETHERSCANKEY") ?? "JGST1ZY7VTCFDCU5PXTMPCBWCY5JA7QCIA"
        static let binanceSmartChainExplorerApiKey: String? = env("BINANCESMARTCHAINEXPLORERAPIKEY") ?? "BN85QQZAWGTSFPWCU3M4VQ6C7HNXTUBG5F"
        static let polygonScanExplorerApiKey: String? = env("POLYGONSCANEXPLORERAPIKEY") ?? "DI5EXE24AKK6C3HSPP718D4UZHWK92QHXX"
        static let avalancheExplorerApiKey = env("AVALANCHEEXPLORERAPIKEY")
        static let paperTrail = (host: env("PAPERTRAILHOST") ?? "", port: (env("PAPERTRAILPORT") ?? "").toInt() ?? 0)
        static let openseaKey = env("OPENSEAKEY") ?? nil
        static let rampApiKey = env("RAMPAPIKEY") ?? "k4jnfagsmjemjbfaxocxsnbtq2g76wfyvkdv42cs"
        static let coinbaseAppId = env("COINBASEAPPID") ?? ""
        static let enjinUserName = env("ENJINUSERNAME") ?? "vlad_shepitko@outlook.com"
        static let enjinUserPassword = env("ENJINUSERPASSWORD") ?? "wf@qJPz75CL9Tw$"
        static let unstoppableDomainsV2ApiKey = env("UNSTOPPABLEDOMAINSV2KEY") ?? "Bearer rLuujk_dLBN-JDE6Xl8QSCg-FeIouRKM"
        static let blockscanChatProxyKey = env("BLOCKSCHATPROXYKEY") ?? ""
        static let covalentApiKey = env("COVALENTAPIKEY") ?? "ckey_12ee4a2d24db45f39c4b6c4df6e"
        //Without the "Basic " prefix
        static let klaytnRpcNodeKeyBasicAuth = env("KLAYTNRPCNODEKEYBASICAUTH") ?? ""
    }
}

extension Constants.Credentials {
    public enum functional {}
}

extension Constants.Credentials.functional {
    public static func extractKeyValueCredentials(_ line: String) -> (key: String, value: String)? {
        let keyValue = line.components(separatedBy: "=")
        if keyValue.count == 2 {
            return (keyValue[0], keyValue[1])
        } else if keyValue.count > 2 {
            //Needed to handle when = is in the API value, example Basic Auth
            return (keyValue[0], keyValue[1..<keyValue.count].joined(separator: "="))
        } else {
            return nil
        }
    }
}
