//
//  Data + Extension.swift
//  LegalRemit
//
//  Created by Amrit Duwal on 12/23/21.
//  Copyright © 2021 View9. All rights reserved.
//

import Foundation

extension Data {
    
    var jsonString: String? { //prettyPrintedBody
        guard
            let object = try? JSONSerialization.jsonObject(with: self, options: []),
            let prettyPrintedData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let prettyPrintedBody = String(data: prettyPrintedData, encoding: .utf8)
        else {
            return nil
        }
        
        return prettyPrintedBody
    }
    
}
