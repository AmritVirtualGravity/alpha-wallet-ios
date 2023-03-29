
import Foundation
import UIKit

fileprivate let currencyBehavior = NSDecimalNumberHandler(roundingMode: .bankers, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)

extension Decimal {
    var rC: Decimal {
        return (self as NSDecimalNumber).rounding(accordingToBehavior: currencyBehavior) as Decimal
    }
}

extension Formatter {
    
    static let withCurrencySeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.currencySymbol = "$"
        formatter.decimalSeparator = "."
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 4
        formatter.numberStyle = .currency
        return formatter
        //Result = $123,456.11
    }()
    
    static let withNepalCurrencySeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.currencySymbol = "Rs."
        formatter.decimalSeparator = "."
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .currency
        
//        formatter.locale = Locale(identifier: "en_AU") // france localization used just to change the currency to last
        return formatter
            //Result = 123,456.11 AUD
    }()
    
    static let withoutCurrencySeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        
        return formatter
        //Result = 23,456.11
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
    
    static let maxFraction1: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        return formatter
        //Result = $123,456.11  //123.23
    }()
    
    static let noGroupingSeperator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        return formatter
            //Result = $123,456.11
    }()
    
    
    static let noGroupingSeperatorWithFractionDigitFour: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 4
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        return formatter
            //Result = $123,456.11
    }()
    
}

extension Int {
    var string: String {
        return String(self)
    }
}

extension Double {
    
    // book gara
    var amount: String {
        return Formatter.withNepalCurrencySeparator.string(for: self) ?? ""
    }
    
    var rating: String {
        return Formatter.maxFraction1.string(for: self) ?? ""
    }
    
    //unused
    var dollar: String {
        return Formatter.withCurrencySeparator.string(for: self) ?? ""
    }
    
    var fractionNumber: String {
        return Formatter.minFraction0.string(for: self) ?? ""
    }
    
    var string: String {
        return String(self)
    }
    
}

extension Decimal {
    
    var dollar: String {
        return Formatter.withCurrencySeparator.string(for: self) ?? ""
    }
    
    var ausAmt: String {
        return String(Formatter.withoutCurrencySeparator.string(for: self) ?? "") + " AUD"
    }
    
    var formattedWithSeparator: String {
        return Formatter.withCurrencySeparator.string(for: self) ?? ""
    }
    
    var formattedWithoutSeparator: String {
        return Formatter.withoutCurrencySeparator.string(for: self) ?? ""
    }
    
    // book gara
    var amount: String {
        return Formatter.withNepalCurrencySeparator.string(for: self) ?? ""
    }
    
    var fourDigitAmount: String {
        return Formatter.noGroupingSeperatorWithFractionDigitFour.string(for: self) ?? ""
    }
    
    var percentFormat: String {
        return String(Formatter.withoutCurrencySeparator.string(for: self) ?? "") + "%"
    }
}

extension String {
    
    var amount: String {
        return Formatter.withNepalCurrencySeparator.string(for: Double(self)) ?? ""
    }
    var fractionNumber: String {
        return Formatter.minFraction0.string(for: Double(self)) ?? ""
    }
    var fractionNumberDouble: Double {
        return Double(Formatter.minFraction0.string(for: Double(self)) ?? "") ?? 0
    }
    
    var decimal: Decimal {
        return Decimal(Double(self) ?? 0)
    }
}


extension Decimal {
    var doubleValue:Double {
        return NSDecimalNumber(decimal:self).doubleValue
    }
}

extension Decimal {
    var significantFractionalDecimalDigits: Int {
        return max(-exponent, 0)
    }
}
