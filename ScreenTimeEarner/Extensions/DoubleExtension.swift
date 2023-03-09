//
//  DoubleExtensions.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import Foundation
import SwiftUI

//MARK: - Double
extension Double {
    var currency: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currencyAccounting
        return numberFormatter.string(for: self) ?? ""
    }
    
    var currencyABS: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currencyAccounting
        numberFormatter.maximumFractionDigits = .zero
        return numberFormatter.string(for: self) ?? ""
    }
    
    var string: String {
        return String(self)
    }
    
    var cgfloat: CGFloat {
        return CGFloat(truncating: NSNumber(value: self))
    }
    
    var shortenedCurrency: String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currencyAccounting
                
        if self >= 1000 && self < 999999.999999999999999 {
            return "$\(String(format: "%.1fK", self / 1000).replacingOccurrences(of: ".0", with: ""))"
        }
        if self >= 1000000 {
            return "$\(String(format: "%.2fM", self / 1000000).replacingOccurrences(of: ".00", with: ""))"
        }
        
        return numberFormatter.string(for: self) ?? ""
    }
    
    var int64: Int64 {
        return Int64(self)
    }
    
    var time: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        let formattedString = formatter.string(from: TimeInterval(self))!
        
        return formattedString
    }
    
    var timeText: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .spellOut
        formatter.allowedUnits = [.hour, .minute, .second]
        let formattedString = formatter.string(from: TimeInterval(self))!
        
        return formattedString
    }
}
