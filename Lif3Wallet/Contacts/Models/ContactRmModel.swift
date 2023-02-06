//
//  contact.swift
//  Lif3Wallet
//
//  Created by Vanila Tech Bibhut on 2/6/23.
//

import Foundation
import RealmSwift
import UIKit



class ContactRmModel: Object {
  
    @objc dynamic var name  = ""
    @objc dynamic var walletAddress = ""
    
    convenience init(name: String, walletAddress:String) {
         self.init()
         self.name = name
         self.walletAddress = walletAddress
     }
}
