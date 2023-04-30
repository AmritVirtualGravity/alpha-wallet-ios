    //
    //  GlobalConstants.swift
    //
    //
    //  Created by Mac on 7/10/20.
    //  Copyright © 2020 Amrit Duwal. All rights reserved.
    //

import UIKit
import CoreLocation
#if PRODUCTION
import Alamofire
#else
#endif
//import Frames

//struct Colors {
//
//    static let themeColor                = #colorLiteral(red: 0.4745098039, green: 0.2745098039, blue: 0.8705882353, alpha: 0.8) // 7946DE opacity 84%
//    static let mediumBlack               = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1) // 666666
//    static let highBlack                 = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1) // 333333
//    static let lightBlack                = #colorLiteral(red: 0.9098039216, green: 0.9098039216, blue: 0.9098039216, alpha: 1) // E8E8E8
//    static let shadowColor               = #colorLiteral(red: 0.6470588235, green: 0.6352941176, blue: 0.6352941176, alpha: 1) // A5A2A2
//    static let purpleColor               = #colorLiteral(red: 0.7254901961, green: 0.3843137255, blue: 0.9137254902, alpha: 1) // B962E9
//    static let lightWhitebackGroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1) // F9F9F9
//    static let darkpurple                = #colorLiteral(red: 0.368627451, green: 0.09019607843, blue: 0.9215686275, alpha: 1) // 5E17EB
//    static let lightPurple               = #colorLiteral(red: 0.968627451, green: 0.9098039216, blue: 1, alpha: 1) // F7E8FF
//    static let transparentView           = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.35) // 000000 35%
//    static let skyBlue                   = #colorLiteral(red: 0.3568627451, green: 0.7333333333, blue: 1, alpha: 1) // 5BBBFF
//    static let lightSkyBlue              = #colorLiteral(red: 0.9411764706, green: 0.9725490196, blue: 1, alpha: 1) // F0F8FF
//    static let yellowColor               = #colorLiteral(red: 0.9098039216, green: 0.937254902, blue: 0.1960784314, alpha: 1)
//    static let lightRedColor             = #colorLiteral(red: 0.9450980392, green: 0.4431372549, blue: 0.4, alpha: 1)
//
//    // pickedFromColorPicker
//    static let darkPurple                = #colorLiteral(red: 0.6438743472, green: 0.2011263967, blue: 0.9128372073, alpha: 1) // A433E9
//    static let blueColor = #colorLiteral(red: 0.2705882353, green: 0.6235294118, blue: 0.9725490196, alpha: 1) //459FF8
//
////    ***** Unused****
//    static let lightBlue             = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
//    static let green                 = #colorLiteral(red: 0.1058823529, green: 0.6352941176, blue: 0.3803921569, alpha: 1)
//    static let greenColor            = #colorLiteral(red: 0.1058823529, green: 0.6352941176, blue: 0.3803921569, alpha: 1) // 1BA261
//    static let lightRed              = #colorLiteral(red: 1, green: 0.8408887982, blue: 0.833807826, alpha: 1)
//    static let lightGreen            = #colorLiteral(red: 0.8549019608, green: 0.937254902, blue: 0.8862745098, alpha: 1)
//    static let grey                  = #colorLiteral(red: 0.8196078431, green: 0.8196078431, blue: 0.8196078431, alpha: 1)
//    static let greyColor             = #colorLiteral(red: 0.8196078431, green: 0.8196078431, blue: 0.8196078431, alpha: 1)
//    static let greyWithOpacity       = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 0.6)
//    static let greenWithOpacity      = #colorLiteral(red: 0.1058823529, green: 0.6352941176, blue: 0.3803921569, alpha: 0.6)
//
//    static let pinkColor             = #colorLiteral(red: 0.9098039216, green: 0.2549019608, blue: 0.5529411765, alpha: 1) //E8418D
//    static let lightPinkColor        = #colorLiteral(red: 0.937254902, green: 0.3647058824, blue: 0.6196078431, alpha: 1) //EF5D9E
//    static let primaryBlue           = UIColor.systemBlue
//    static let primaryColor          = #colorLiteral(red: 1, green: 0.6078431606, blue: 0.4666666687, alpha: 1)
//    static let primaryBrownColor     = #colorLiteral(red: 0.9333333333, green: 0.8901960784, blue: 0.8588235294, alpha: 1)
//    static let restaurantTheme       = pinkColor
//    static let darkColor             = #colorLiteral(red: 0.121294491, green: 0.1292245686, blue: 0.141699791, alpha: 1)
//    static let lightGreyColor        = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
////    static let blueColor             = pinkColor
//    static let darkGreyColor         = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1) //555555
//    static let primaryRed            = #colorLiteral(red: 0.9450980392, green: 0.4431372549, blue: 0.4, alpha: 1) // F17166
//    static let textFieldBackground   = #colorLiteral(red: 0.9500576854, green: 0.9476057887, blue: 0.9688865542, alpha: 1)
//    static let transparentBlackColor = darkColor.withAlphaComponent(0.6)
////    static var thirdColor            = blueColor.withAlphaComponent(0.6)
//    static var secondColor: UIColor  = UIColor.white
//
//}
 // swiftui
let greenColor        = #colorLiteral(red: 0, green: 0.7843137255, blue: 0.5921568627, alpha: 1) // 00C897
let lightestGreyColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) // #FFFFFF
let lighterGreyColor  = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1) // #F9F9F9
let lightGreyColor    = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9529411765, alpha: 1) // F2F2F3
let darkestGreyColor  = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1) // 212121

//let darkestGreyColor  = pinkColor
let themeColor        = pinkColor
//let darkerGreyColor   = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1) //666666
let darkGreyColor     = #colorLiteral(red: 0.6196078431, green: 0.6196078431, blue: 0.6196078431, alpha: 1) //#9E9E9E
let redColor          = #colorLiteral(red: 0.9529411765, green: 0.3137254902, blue: 0.3137254902, alpha: 1) //F35050
let yellowColor       = #colorLiteral(red: 0.9529411765, green: 0.7764705882, blue: 0.3137254902, alpha: 1) //F3C650
let lightYellowColor  = #colorLiteral(red: 1, green: 0.9843137255, blue: 0.9490196078, alpha: 1) //FFFBF2

//let lightYellowColor  = #colorLiteral(red: 1, green: 0.9843137255, blue: 0.9490196078, alpha: 1) //FFFBF2

let darkestGreyColorDim = darkestGreyColor.withAlphaComponent(0.4)
// MARK: For Lif3 app
let darkestBlack = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)  //000000
let darkerSecondLastBlack = #colorLiteral(red: 0.09411764706, green: 0.09411764706, blue: 0.09411764706, alpha: 1)  //181818
let darkerBlack = #colorLiteral(red: 0.07843137255, green: 0.07843137255, blue: 0.07843137255, alpha: 1)  //1E1E1E
let darkColor    = #colorLiteral(red: 0.137254902, green: 0.137254902, blue: 0.137254902, alpha: 1) //#232323
let lightestDarkColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) //#FFFFFF
let lighterDarkColor = #colorLiteral(red: 0.8143547177, green: 0.8143547177, blue: 0.8143546581, alpha: 1) //#888888
let lightDarkColor = #colorLiteral(red: 0.5333333333, green: 0.5333333333, blue: 0.5333333333, alpha: 1) //#888888

let blueColor  = #colorLiteral(red: 0.1837692261, green: 0.5399141908, blue: 0.9605662227, alpha: 1) //CAA7D1


let pinkColor  = #colorLiteral(red: 0.7921568627, green: 0.6549019608, blue: 0.8196078431, alpha: 1) //CAA7D1

//struct Fonts {
//
//    //Regular
//    static let openSansRegular14 = UIFont.OpenSans(.regular, size: 14)
//    static let openSansRegular16 = UIFont.OpenSans(.regular, size: 16)
//    //Semibold
//    static let openSansSemiBold14 =  UIFont.OpenSans(.semibold, size: 14)
//    static let openSansSemiBold16 =  UIFont.OpenSans(.semibold, size: 16)
//
//    static let openSansBold16 =  UIFont.OpenSans(.bold, size: 16)
//    static let openSansBold14 =  UIFont.OpenSans(.bold, size: 14)
//}


struct GlobalConstants {
    
    static var showProfileActive = false
    static var backButtonBounds: CGRect?

    struct KeyValues {
        
//        static var backgroundEnterDate: Date?
        
//        static var globalDeliveryMethod: DeliveryMethod? {
//            get {
//                return decode(key: "globalDeliveryMethod")
//            }
//            set {
//                encodeAndSave(key: "globalDeliveryMethod", value: newValue)
//            }
//        }
//
//        static var globalCountry: LegalRemitCountry? {
//            get {
//                return decode(key: "globalCountry")
//            }
//            set {
//                encodeAndSave(key: "globalCountry", value: newValue)
//            }
//        }
//
//        // for developement only
//        static var dummyImage: Data? {
//            get {
//                return decode(key: "globalCountry")
//            }
//            set {
//                encodeAndSave(key: "globalCountry", value: newValue)
//            }
//        }
//
//
//        // for developement only
//        static var chatNoticationCount: Int {
//            get {
//                return decode(key: "chatNoticationCount") ?? 0
//            }
//            set {
//                encodeAndSave(key: "chatNoticationCount", value: newValue)
//            }
//        }

        
        static func apiCache<T: Codable>(key: String) -> T? {
            let cache = UserDefaults.standard.dictionary(forKey: "URLCache") as? [String: Data]
            guard let data = cache?[key] else {return nil}
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                debugPrint(error)
                return nil
            }
        }
        
        static func apiCache<T: Codable>(key: String, data: T) {
            var cache = (UserDefaults.standard.dictionary(forKey: "URLCache") as? [String: Data]) ?? [:]
            cache[key] = try? JSONEncoder().encode(data)
            UserDefaults.standard.set(cache, forKey: "URLCache")
        }
        
        static private func encodeAndSave<T: Encodable>(key: String, value: T) {
            if let encoded = try? JSONEncoder().encode(value) {
                UserDefaults.standard.set(encoded, forKey: key)
            }
        }
        
        
        static private func decode<T: Decodable>(key: String) -> T? {
            if let data = UserDefaults.standard.object(forKey: key) as? Data {
                return try? JSONDecoder().decode(T.self, from: data)
            }
            return nil
        }
    }
    
    struct Error {
        static var tokenExpired: NSError { NSError(domain: "Unauthorized user", code: 500, userInfo: [NSLocalizedDescriptionKey: "Your session has expired"])}
        static var configureEmail: NSError { NSError(domain: "EMAIL_NOT_CONFIGURED", code: 500, userInfo: [NSLocalizedDescriptionKey: "configure_email"])}
        static var emailNotSent: NSError { NSError(domain: "EMAIL_ERROR", code: 500, userInfo: [NSLocalizedDescriptionKey: "email_not_sent"])}
        static var emailFieldEmpty: NSError { NSError(domain: "EMAIL_VALIDATION", code: 500, userInfo: [NSLocalizedDescriptionKey: "Email is empty"])}
        static var passwordFieldEmpty: NSError { NSError(domain: "PASSWORD_VALIDATION", code: 500, userInfo: [NSLocalizedDescriptionKey: "Password is empty"])}
        static var passwordConfirmationFieldEmpty: NSError { NSError(domain: "PASSWORDCONFIRMATION_VALIDATION", code: 500, userInfo: [NSLocalizedDescriptionKey: "Confirmation Password is empty"])}
        static var invalidEmail: NSError { NSError(domain: "EMAIL_VALIDATION", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid Email"])}
        static var usernameFieldEmpty: NSError { NSError(domain: "USERNAME_VALIDATION", code: 500, userInfo: [NSLocalizedDescriptionKey: "username_empty"])}
        static var invalidUsername: NSError { NSError(domain: "USERNAME_VALIDATION", code: 500, userInfo: [NSLocalizedDescriptionKey: "username_invalid"]) }
        static var selectLanguage: NSError { NSError(domain: "LANGUAGE_SELECTION_VALIDATION", code: 500, userInfo: [NSLocalizedDescriptionKey: "please_select_language"]) }
        static var selectNationality: NSError { NSError(domain: "NATIONALITY_SELECTION_VALIDATION", code: 500, userInfo: [NSLocalizedDescriptionKey: "please_select_nationality"]) }
        static var gotoLogin: NSError { NSError(domain: "Session Expired", code: 500, userInfo: [NSLocalizedDescriptionKey: "oops"])}
        static var oops: NSError { NSError(domain: "API_ERROR", code: 500, userInfo: [NSLocalizedDescriptionKey: "Something went wrong"])}
        
        static var loginError: NSError { NSError(domain: "API_ERROR", code: 500, userInfo: [NSLocalizedDescriptionKey: "Something went wrong? have you entered email address or password incorrectly?"])}
        
        static var sessionNotValid: NSError { NSError(domain: "API_ERROR", code: 500, userInfo: [NSLocalizedDescriptionKey: "Session is invalid, Please login again."])}
        static var creditCardChargeFailedSalon: NSError { NSError(domain: "API_ERROR", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to charge with this credit card."])}
        
        static var emptyData: NSError { NSError(domain: "Data Empty", code: 205, userInfo: [NSLocalizedDescriptionKey: "Data is Empty."])}
    }
    
    struct Strings {
        static var checkinSuccess: String = "CheckIn successful"
        static var bookSuccess: String = "Successful booked"
        static var supportMessageSuccess: String = "Your message was sent successfully. You will receive response on the email provided on your profile"
    }
    
    struct version {
        static var appStoreVersion = ""
        static var apiAppVersion   = 0.0
        static var majorUpdate     = false
        static var minorUpdate     = false
    }
    
}

//func appName() -> String {
//    let appName = Bundle.main.displayName ?? ""
//    return "iOS\(appName.removeWhiteSpace)"
//}
//
//func displayName() -> String {
//    return Bundle.main.displayName ?? ""
//}


struct CurrentHeaderBodyParameter {
    static var request: URLRequest?
    static var body: [String: Any]?
    static var header: URLRequest?
}
