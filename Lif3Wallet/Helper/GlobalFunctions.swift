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
