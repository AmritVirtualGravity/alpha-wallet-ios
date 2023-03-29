//
//  Colors.swift
//  gyre_rider
//
//  Created by Amir Rimal on 07/10/2021.
//

import UIKit


extension UIColor {
    
    /// Helper method to verify and return color if assets has it
    /// - Parameter colorName: the name of color from asset
    /// - Returns: the color from name
    private static func named(_ colorName: String) -> UIColor {
        guard let color = UIColor(named: colorName) else {
            fatalError("The color associted with name \(colorName) counld not be found. Please check that you spelled it correctly.")
        }
        return color
    }
    
    ///3893B0
    static var superManColor: UIColor {  UIColor.named("SuperManColor")  }
    static var superManColorDim: UIColor {  UIColor.named("SuperManColorDim")  }
    static var wonderWomanColor: UIColor {  UIColor.named("WonderWomanColor")  }
    static var wonderWomanColorDim: UIColor {  UIColor.named("WonderWomanColorDim")  }
    static var appTextHighContrastColor: UIColor {  UIColor.named("AppTextHighContrastColor")  }
    static var appTextLowContrastColor: UIColor {  UIColor.named("AppTextLowContrastColor")  }
    static var appBackgroundColor: UIColor {  UIColor.named("AppBackgroundColor")  }
    static var oppositeHighContrastColor: UIColor {  UIColor.named("OppositeHighContrastColor")  }
    static var secondaryButtonColor: UIColor {  UIColor.named("SecondaryButtonColor")
    }
    static var lightGreyWhite: UIColor {  UIColor.named("LightGreyWhite")
    }
    
    static var lightGreyAndDarkColor: UIColor {  UIColor.named("LightGreyAndDarkColor") }
    static var whiteAndDarkGreyColor: UIColor {  UIColor.named("WhiteAndLightGrey") }
    static var greyAndDarkGrey: UIColor {
        UIColor.named("GreyAndDarkGrey") }
    static var greyAndWhiteColor: UIColor {
        UIColor.named("GreyAndWhiteColor") }
    
    
//    static var secondaryButtonColor: UIColor {  UIColor.named("SecondaryButtonColor") }
    
    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
            
        } else {
            
            return nil
        }
    }
    
    
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

