//
//  LifeDataSource.swift
//  AlphaWallet
//
//  Created by Vanila Tech Bibhut on 11/3/22.
//

import Foundation
class LifeDateSource {
    
    static var privateShared:LifeDateSource?
    
    class func shared() -> LifeDateSource {
        guard let uwShared = privateShared else {
            privateShared = LifeDateSource()
            return privateShared!
        }
        return uwShared
    }
    
    var isForSwap = false
}
