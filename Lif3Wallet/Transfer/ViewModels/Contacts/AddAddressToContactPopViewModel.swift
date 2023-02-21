//
//  AddAddressToContactViewModel.swift
//  Lif3Wallet
//
//  Created by Vanila Tech Bibhut on 2/21/23.
//
import UIKit

struct AddAddressToContactPopViewModel {
    let titleText: String = "Name"
    var font: UIFont = Fonts.semibold(size: 15)
    var textColor: UIColor = .white
    var backgroundColor: UIColor = Configuration.Color.Semantic.defaultViewBackground
    let buttonTitleText : String = "Add To Contact"
    let placeHolder: String = "eg. Tom Henderson"
}

