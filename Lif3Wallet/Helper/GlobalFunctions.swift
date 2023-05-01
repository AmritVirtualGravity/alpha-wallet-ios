//
//  GlobalFunctions.swift
//  Lif3Wallet
//
//  Created by Amrit Duwal on 4/17/23.
//

import Foundation


//func printGlobal(){
//
//}

//func printGlobal(_ sender: AnyObject?) {
//    print(sender)
//}


// create a generic function
func printGlobal<T>(data: T) {
 print("Generic Function:")
 print("Data Passed:", data)
}


func returnServerImageUrl(symbol: String)  -> String{
//        return "https://assets.lif3.com/wallet/chains/\(symbol)-Isolated.svg"
    return "https://assets.lif3.com/wallet/chains/\(symbol).svg"
}
