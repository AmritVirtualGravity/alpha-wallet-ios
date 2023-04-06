//
//  LoginViewModel.swift
//  Book Gara
//
//  Created by Amrit Duwal on 6/10/22.
//

import Foundation

class ContentViewModel: ObservableObject, PoolAPI {
    
    @Published var pools: [Pool]?
    @Published var isBusy = true
    @Published var error: Error?
    
    var showAlert: Bool?
    
    func getPool(name: String) {
        isBusy = true
        getPool(name: name) { poolParent in
            self.pools = poolParent.pools
            self.isBusy = false
        } failure: { error in
            self.isBusy    = false
            self.showAlert = true
            self.error     = error
        }
    }
    
}
