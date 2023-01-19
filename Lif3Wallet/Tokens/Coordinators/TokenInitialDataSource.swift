//
//  TokenInitialDataSource.swift
//  Lif3Wallet
//
//  Created by Vanila Tech Bibhut on 1/9/23.
//

import Foundation
//

import Foundation

class TokenInitialDataSource {
    
    static var privateShared:TokenInitialDataSource?
    
    class func shared() -> TokenInitialDataSource {
        guard let uwShared = privateShared else {
            privateShared = TokenInitialDataSource()
            return privateShared!
        }
        return uwShared
    }
    
    var blackListedTokenArr: [String]?
    
  
  
   
    // Helper Methods
    class func reset() {
        privateShared =  nil
    }
}
