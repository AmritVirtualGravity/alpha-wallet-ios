//
//  ContactListViewModel.swift
//  Lif3Wallet
//
//  Created by Bibhut on 2/7/23.
//


import UIKit
import RealmSwift

struct ContactListViewModel {
    
    let rowHeight: CGFloat = 60

     func getContacts() -> [ContactRmModel] {
        let realm = try! Realm()
        let items = realm.objects(ContactRmModel.self)
        return Array(items)
    }
}
