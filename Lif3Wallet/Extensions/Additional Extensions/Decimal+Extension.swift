//
//  Decimal+Extension.swift
//  Restaurant
//
//  Created by Amrit Duwal on 10/16/20.
//  Copyright © 2020 Amrit Duwal. All rights reserved.
//

import Foundation
import UIKit

fileprivate let currencyBehavior = NSDecimalNumberHandler(roundingMode: .bankers, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
//fileprivate let currencyBehavior = NSDecimalNumberHandler(roundingMode: .down, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)

extension Decimal {
    var rC: Decimal { // rc means roundedCurrency
        return (self as NSDecimalNumber).rounding(accordingToBehavior: currencyBehavior) as Decimal
    }
}

extension Formatter {
    static let withDecimalSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "_"
        formatter.decimalSeparator = "."
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        
        return formatter
        //Result = 123_456.11
    }()
    
    static let withCurrencySeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.currencySymbol = "$"
        formatter.decimalSeparator = "."
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .currency
        
        return formatter
        //Result = $123,456.11
    }()
    
    static let withoutCurrencySeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        
        return formatter
        //Result = $123,456.11  //123.23
    }()
    
    static let minFraction0: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        return formatter
        //Result = $123,456.11  //123.23
    }()
    
}

extension Double {
    var formattedWithSeparator1: String {
        return Formatter.withDecimalSeparator.string(for: self) ?? ""
    }
    var dollar: String {
        return Formatter.withCurrencySeparator.string(for: self) ?? ""
    }
    var fractionNumber: String {
        return Formatter.minFraction0.string(for: self) ?? ""
    }
    var fractionNumberDouble: Double {
        return Double(Formatter.minFraction0.string(for: self) ?? "") ?? 0
    }
}


extension Decimal {
//    var formattedWithSeparator1: String {
//        return Formatter.withDecimalSeparator.string(for: self) ?? ""
//    }
    var dollar: String {  // $ 0.00
        return Formatter.withCurrencySeparator.string(for: self) ?? ""
    }
    
    var formattedWithoutSeparator: String {
          return Formatter.withoutCurrencySeparator.string(for: self) ?? ""
      }
    
    var fractionNumber: String {
        return Formatter.minFraction0.string(for: self) ?? ""
    }
}


extension Decimal {
    var doubleValue:Double {
        return NSDecimalNumber(decimal:self).doubleValue
    }
}

//// implementation
//let d = Decimal(floatLiteral: 10.65)
//d.doubleValue
