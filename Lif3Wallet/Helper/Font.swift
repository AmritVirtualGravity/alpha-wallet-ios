import Foundation
import UIKit

//let regularFont34 = BookGaraFont(.installed(.galanoGrostesqueRegular), size:.custom(34)).instance
//let regularFont18 = BookGaraFont(.installed(.galanoGrostesqueRegular), size:.custom(18)).instance
//let regularFont16 = BookGaraFont(.installed(.galanoGrostesqueRegular), size:.custom(16)).instance
//let regularFont14 = BookGaraFont(.installed(.galanoGrostesqueRegular), size:.custom(14)).instance
//let regularFont12 = BookGaraFont(.installed(.galanoGrostesqueRegular), size:.custom(12)).instance
//
//
//let boldFont18 = BookGaraFont(.installed(.galanoGrostesqueBold), size: .custom(18)).instance
//let boldFont16 = BookGaraFont(.installed(.galanoGrostesqueBold), size: .custom(16)).instance
//let boldFont14 = BookGaraFont(.installed(.galanoGrostesqueBold), size: .custom(14)).instance
//
//let mediumFont24 = BookGaraFont(.installed(.galanoGrostesqueMedium), size: .custom(20)).instance
//let mediumFont20 = BookGaraFont(.installed(.galanoGrostesqueMedium), size: .custom(20)).instance
//let mediumFont18 = BookGaraFont(.installed(.galanoGrostesqueMedium), size: .custom(18)).instance
//let mediumFont16 = BookGaraFont(.installed(.galanoGrostesqueMedium), size: .custom(16)).instance
//let mediumFont14 = BookGaraFont(.installed(.galanoGrostesqueMedium), size: .custom(14)).instance
//let mediumFont12 = BookGaraFont(.installed(.galanoGrostesqueMedium), size: .custom(12)).instance


let regularFont34 = UIFont.systemFont(ofSize: CGFloat(34), weight: .regular)
let regularFont18 = UIFont.systemFont(ofSize: CGFloat(18), weight: .regular)
let regularFont16 = UIFont.systemFont(ofSize: CGFloat(16), weight: .regular)
let regularFont14 = UIFont.systemFont(ofSize: CGFloat(14), weight: .regular)
let regularFont12 = UIFont.systemFont(ofSize: CGFloat(12), weight: .regular)


let boldFont18    = UIFont.systemFont(ofSize: CGFloat(18), weight: .bold)
let boldFont16    = UIFont.systemFont(ofSize: CGFloat(16), weight: .bold)
let boldFont14    = UIFont.systemFont(ofSize: CGFloat(14), weight: .bold)

let mediumFont24  = UIFont.systemFont(ofSize: CGFloat(24), weight: .medium)
let mediumFont20  = UIFont.systemFont(ofSize: CGFloat(20), weight: .medium)
let mediumFont18  = UIFont.systemFont(ofSize: CGFloat(18), weight: .medium)
let mediumFont16  = UIFont.systemFont(ofSize: CGFloat(16), weight: .medium)
let mediumFont14  = UIFont.systemFont(ofSize: CGFloat(14), weight: .medium)
let mediumFont12  = UIFont.systemFont(ofSize: CGFloat(12), weight: .medium)



enum FontType {
    case regular, medium, bold
}

struct BookGaraFont {
    
    enum TypeFont {
        case installed(FontName)
        case custom(String)
        case system
        //        case systemBold
        //        case systemItatic
        //        case systemWeighted(weight: Double)
        //        case monoSpacedDigit(size: Double, weight: Double)
        
    }
    enum FontSize {
        case standard(StandardSize)
        case custom(Double)
        var value: Double {
            switch self {
            case .standard(let size):
                return size.rawValue
            case .custom(let customSize):
                return customSize
            }
        }
    }
    enum FontName: String {
        //        case galanoGrotesqueLight    = "Galano Grotesque Light"
        //        case galanoGrostesqueRegular = "Galano Grotesque"
        //        case galanoGrostesqueMedium  = "Galano Grotesque Medium"
        //        case galanoGrostesqueBold    = "Galano GrotesqueBold"
        case galanoGrotesqueLight    = "GalanoGrotesque-Light"
        case galanoGrostesqueRegular = "GalanoGrotesque-Regular"
        case galanoGrostesqueMedium  = "GalanoGrotesque-Medium"
        case galanoGrostesqueBold    = "GalanoGrotesque-Bold"
    }
    enum StandardSize: Double {
        case h1 = 20.0
        case h2 = 18.0
        case h3 = 16.0
        case h4 = 14.0
        case h5 = 12.0
        case h6 = 10.0
    }
    var type: TypeFont
    var size: FontSize
    init(_ type: TypeFont, size: FontSize) {
        self.type = type
        self.size = size
    }
}

extension BookGaraFont {
    
    var instance: UIFont {
        
        var instanceFont: UIFont!
        switch type {
        case TypeFont.custom(let fontName):
            guard let font =  UIFont(name: fontName, size: CGFloat(size.value)) else {
                fatalError("\(fontName) font is not installed, make sure it added in Info.plist and logged with Utility.logAllAvailableFonts()")
            }
            instanceFont = font
        case TypeFont.installed(let fontName):
            guard let font =  UIFont(name: fontName.rawValue, size: CGFloat(size.value)) else {
                fatalError("\(fontName.rawValue) font is not installed, make sure it added in Info.plist and logged with Utility.logAllAvailableFonts()")
            }
            instanceFont = font
        case TypeFont.system:
            instanceFont = UIFont.systemFont(ofSize: CGFloat(size.value))
        }
        return instanceFont
    }
}

class Utility {
    /// Logs all available fonts from iOS SDK and installed custom font
    class func logAllAvailableFonts() {
        for family in UIFont.familyNames {
            print("\(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   \(name)")
            }
        }
    }
}
