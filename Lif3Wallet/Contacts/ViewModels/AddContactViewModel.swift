

import UIKit
import RealmSwift

struct AddContactViewModel {

    var addressLabel: String {
        return R.string.localizable.contractAddress()
    }


    var nameLabel: String {
        return R.string.localizable.name()
    }
    
    
     func addContacts(name:String, address: String) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(ContactRmModel(name:name, walletAddress: address))
        }
    }
    
     func getContacts() -> [ContactRmModel] {
        let realm = try! Realm()
        let items = realm.objects(ContactRmModel.self)
        return Array(items)
    }
    
    func updateContacts(index: Int, name: String, address: String) {
        let realm = try! Realm()
        let contact = realm.objects(ContactRmModel.self)[index]
        try! realm.write {
            contact.name = name
            contact.walletAddress = address
        }
    }
}
