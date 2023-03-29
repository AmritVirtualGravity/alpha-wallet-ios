

//
//  TestHelper.swift
//  LegalRemit
//
//  Created by Amrit Duwal on 2/4/23.
//  Copyright © 2023 View9. All rights reserved.
//

import Foundation

class PreviewData {
    
    private func testDecode<T:Codable>(myCustomClass : T.Type, jsonData: Data , success: @escaping (T)->()) {
        do {
            let decoder = JSONDecoder()
            let data = try decoder.decode(T.self, from: jsonData)
            print(data)
            success(data)
        } catch let error {
            print("TestHelper error: \(error)")
        }
    }
    
    static func load<T: Codable> (name: String) -> T? {
        if let path = Bundle.main.path(forResource: name, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let results = try JSONDecoder ().decode (T.self, from: data)
                return results
            } catch {
                return nil
            }
        }
        return nil
    }
    
func debugMode() {
    let jsonData = """
    "lif3_staking_list": [
    "name": "LIF3 Trade"
    "icon":"icon url"
    "tvl":"$99,800"
    "apr": "133.889"
    "token": "FTM"
    "name": "LIF3 Greenhoues"
    "icon": "icon url".
    "tvl":"$99,800"
    "apr": "133.88%"
    "token": "FTM"
    "crypo_banner_suggested_staking_list": [
    "name": "LIF3 Trade"
    "icon":"icon url"
    "tvl":"$99,800"
    "apr": "133.889"
    "token": "FTM"
    "name": "LIF3 Greenhoues"
    "icon":"icon url"
    "tvl": "$99,800"
    "apr"; "133.889"
    "token": "FTM"
    "tech_suggested_staking_list": I
    "name": "LIF3 Trade"
    "icon":"icon url"
    "tvl":"$99,800"
    "apr": "133.889"
    "token": "FTM"
    "name": "LIF3 Greenhoues"
    "icon":"icon url"
    "tvl":"$99,800"
    "apr"; "133.889"
    "token": "FTM"
    """.data(using: .utf8)!

    
//    testDecode(myCustomClass:  InitiateTransaction.self, jsonData: jsonData, success: { initialTransaction in
//        SharedData.shared.initiateTransaction = initialTransaction
//    })
    
    
}
    

}

