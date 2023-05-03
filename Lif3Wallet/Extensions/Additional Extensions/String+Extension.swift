//
//  String+Extension.swift
//  LegalRemit
//
//  Created by Amrit MacMini 2018 on 2/19/20.
//  Copyright © 2020 Amrit. All rights reserved.
//

import UIKit

extension String {
    func isBlankOrEmpty() -> Bool {

      // Check empty string
      if self.isEmpty {
          return true
      }
      // Trim and check empty string
      return (self.trimmingCharacters(in: .whitespaces) == "")
   }
}

extension String {
        //    var isEmail: Bool {
        //        let emailTest = NSPredicate(format:"SELF MATCHES %@",  "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
        //        return emailTest.evaluate(with: self)
        //    }

    var trimmed: String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    func convertToInternationalFormat() -> String {
        let isMoreThanTenDigit = self.count > 10
        _ = self.startIndex
        var newstr = ""
        if isMoreThanTenDigit {
            newstr = "\(self.dropFirst(self.count - 10))"
        }
        else if self.count == 10{
            newstr = "\(self)"
        }
        else {
            return "number has only \(self.count) digits"
        }
        if  newstr.count == 10 {
            let internationalString = "(\(newstr.dropLast(7))) \(newstr.dropLast(4).dropFirst(3)) \(newstr.dropFirst(6).dropLast(2))\(newstr.dropFirst(8))"
            newstr = internationalString
        }
        return newstr
    }

//    func capitalizingFirstLetter() -> String {
//        return prefix(1).capitalized + dropFirst()
//    }
//    var capitalizeFirstLetter : String {
//        return prefix(1).capitalized + dropFirst()
//    }
    var smallCaseFirstLetter : String {
        return prefix(1).lowercased() + dropFirst()
    }

//    mutating func capitalizeFirstLetter() {
//        self = self.capitalizingFirstLetter()
//    }
}

extension String {
    var removeWhiteSpace: String {
        return self.components(separatedBy: .whitespaces).joined()
    }

    var noWhiteSpaceAndLowerCased: String {
        return self.components(separatedBy: .whitespaces).joined().lowercased()
    }

    var removeLeadingTrailingSpace: String {
        return self.trimmingCharacters(in: .whitespaces)
    }
    
  
}

extension String {

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.width)
    }

}

extension String {

    func camelCaseToWords() -> String {

        return unicodeScalars.reduce("") {

            if CharacterSet.uppercaseLetters.contains($1) {

                return ($0 + " " + String($1))
            }
            else {

                return $0 + String($1)
            }
        }
    }
}

extension String {
    func camelCased(with separator: Character) -> String {
        return self.lowercased()
            .split(separator: separator)
            .enumerated()
            .map { $0.offset > 0 ? $0.element.capitalized : $0.element.lowercased() }
            .joined()
    }

}

extension String {
    var htmlAttributedString: NSAttributedString {
        let data = Data(self.utf8)
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            return attributedString
        }
        return NSAttributedString()
    }

}
    extension String {
        func slice(from: String, to: String) -> String? {

            return (range(of: from)?.upperBound).flatMap { substringFrom in
                (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                    String(self[substringFrom..<substringTo])
                }
            }
        }
    }

 // from legal remit
extension String {
    
    func snakeCased() -> String? {
        let pattern = "([a-z0-9])([A-Z])"
        
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: self.count)
        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2").lowercased()
    }
}


extension String {
    var error: Error {
        return  NSError(domain: "Custom Error", code: 500, userInfo: [NSLocalizedDescriptionKey: self])
    }

    #warning("Later manage this code")
    var success: Error {
        return  NSError(domain: "", code: 200, userInfo: [NSLocalizedDescriptionKey: self])
    }

}


extension String? {
    var isEmptyOrNil: Bool {
        self == nil || self == ""
    }
}

extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}

extension [String: Any]? {
    var jsonStringFormat: String {
        var theJSONText: String = ""
        if let bodyJson = try? JSONSerialization.data(
            withJSONObject: self ?? [:],
            options: .prettyPrinted) {
            theJSONText = String(data: bodyJson,
                                 encoding: .ascii) ?? ""
            print("JSON string = \(theJSONText)")
        }
        return theJSONText
    }
    
}

extension [String: Any] {
    
    var jsonStringFormat: String {
        var theJSONText: String = ""
        if let bodyJson = try? JSONSerialization.data(
            withJSONObject: self,
            options: .prettyPrinted) {
            theJSONText = String(data: bodyJson,
                                 encoding: .ascii) ?? ""
            print("JSON string = \(theJSONText)")
        }
        return theJSONText
    }
    
}

extension [String: String] {
    
    var jsonStringFormat1: String {
        var theJSONText: String = ""
        if let bodyJson = try? JSONSerialization.data(
            withJSONObject: self,
            options: .prettyPrinted) {
            theJSONText = String(data: bodyJson,
                                 encoding: .ascii) ?? ""
            print("JSON string = \(theJSONText)")
        }
        return theJSONText
    }
    
}


func htmlToAttributed(stringData: String) -> NSAttributedString{
    let data1 = Data(stringData.utf8)
    
    if let attributedString = try? NSAttributedString(data: data1, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
        //               yourLabel.attributedText = attributedString
        //               print(attributedString)
        return attributedString
    }
    return NSAttributedString()
}


extension String {
    var url: String {
//        return URL(string: self.replacingOccurrences(of: " ", with: "%20")) ?? URL(string: "https://api.adeyelta.com/image/1625658923Catering.png")!
 return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
    
    var lif3CapitalizeFirstLetter : String {
        return prefix(1).capitalized + dropFirst()
    }
    
}
