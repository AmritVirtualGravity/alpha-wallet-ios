//
//  Date+Extension.swift
//  Bookgara
//
//  Created by Amrit Duwal 2022 on 3/13/20.
//  Copyright © 2022 . All rights reserved.
//

import Foundation
//import Localize_Swift

extension String {
    
//    func toDate(dateFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") -> Date? { //2022-06-14 09:56:44.169000
//           let dateFormatter = DateFormatter()
//           dateFormatter.locale = Locale.init(identifier: "ne")
//           dateFormatter.dateFormat = dateFormat
//           return dateFormatter.date(from: self)
//       }

//    func toDate(dateFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") -> Date? { //2022-06-14 09:56:44.169000
////        let dateFormatter = DateFormatter()
////        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
////        dateFormatter.calendar = Calendar.current
////        print(Locale.current.regionCode)
////
////        dateFormatter.locale = Locale.init(identifier: Locale.current.language.region?.identifier ?? "ne")
////        //           dateFormatter.locale = Locale.init(identifier: "ne")
////        dateFormatter.locale = .current
////        dateFormatter.dateFormat = dateFormat
////        return dateFormatter.date(from: self)
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = dateFormat
//        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
////        dateFormatter.locale = .current
//            dateFormatter.locale = Locale.init()
////        print(dateFormatter.date(from: self))
//        if let date = dateFormatter.date(from: self) {
////            print("UTC: \(dateFormatter.date(from: self)) \(date)\n")
//            dateFormatter.timeZone = TimeZone.current
//            dateFormatter.dateFormat = dateFormat
////            dateFormatter.dateFormat = "h:mm a"
////            print("current: \(Locale.current.language.region?.identifier ?? "failed") \(dateFormatter.date(from: self))\(date) \(TimeZone.current.identifier)\n")
//            return date
//        }
//        return nil
//    }
    
}

extension Date {
//
//    func toString(format: String = "h:mm a yyyy/M/d") -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .long
//        dateFormatter.timeStyle = .short
//        dateFormatter.dateFormat = format
//        dateFormatter.locale = Locale.init()
//        return dateFormatter.string(from: self)
//    }
//
//
//    func toUTCDate(dateFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") -> Date? { //2022-06-14 09:56:44.169000
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = dateFormat
//        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
//        //        dateFormatter.locale = .current
//        dateFormatter.locale = Locale.init()
//        dateFormatter.defaultDate = self
//        return self
//    }
    
    // Convert local time to UTC (or GMT)
      func toGlobalTime() -> Date {
          let timezone = TimeZone.current
          let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
          return Date(timeInterval: seconds, since: self)
      }
    
}
