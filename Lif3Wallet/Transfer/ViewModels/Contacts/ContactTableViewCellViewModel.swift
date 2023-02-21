//
//  ContactTableViewCellViewModel.swift
//  Lif3Wallet
//
//  Created by Vanila Tech Bibhut on 2/20/23.
//


import UIKit

struct ContactTableViewCellViewModel {
    let name: String
    var address: String
    var titleFont: UIFont = Fonts.regular(size: 15)
    var titleTextColor: UIColor = Configuration.Color.Semantic.tableViewCellPrimaryFont
    var subTitleFont: UIFont = Fonts.regular(size: 12)
    var subTitleTextColor: UIColor = Configuration.Color.Semantic.tableViewCellSecondaryFont
    var tableViewCellheight = 50.0
    
    init(name: String, address: String) {
        self.name = name
        self.address = address
    }
    
}


