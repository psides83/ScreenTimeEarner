//
//  CGFloatExtensions.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import Foundation
import SwiftUI

//MARK: - CGFloat
extension CGFloat {
    var currency: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currencyAccounting
        return numberFormatter.string(for: self) ?? ""
    }
    
    var double: Double {
        return Double(self)
    }
    
    var int: Int {
        return Int(self)
    }
    
    static let largeTitle: CGFloat = 36
    static let title2: CGFloat = 28
    static let title3: CGFloat = 24
    static let headline: CGFloat = 20
    static let subheadline: CGFloat = 18
    static let body: CGFloat = 16
    static let callout: CGFloat = 14
    static let caption: CGFloat = 12
    static let caption2: CGFloat = 10
    static let footnote: CGFloat = 8
}
