//
//  UserDefaults+Extension.swift
//  oneeclick
//
//  Created by nirajan shrestha on 1/31/21.
//

import Foundation

extension UserDefaults {
    
    func save<T: Encodable>(customObject object: T, inKey key: String) {
        do {
            let encoded = try JSONEncoder().encode(object)
            self.set(encoded, forKey: key)
        } catch {
            print("This is error for the \(key) \(error)")
        }
    }
    
    func retrieve<T: Decodable>(fromKey key: String) -> T? {
        if let data = UserDefaults.standard.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let object = try? decoder.decode(T.self, from: data) {
                return object
            } else {
                print("Couldnt decode object")
                return nil
            }
        }
        print("Couldnt find key")
        return nil
    }
    
}
