//
//  ColorExtensions.swift
//  RodeoDaily
//
//  Created by Payton Sides on 2/14/23.
//

import Foundation
import SwiftUI

//MARK: - Color
extension Color {
    static let rdGreen = Color("rdGreen")
    static let rdYellow = Color("rdYellow")
    static let rdGray = Color("rdGray")
    static let bgcolor = Color("bgcolor")
    static let appPrimary = Color("app-primary")
    static let appSecondary = Color("app-secondary")
    static let appTertiary = Color("app-tertiary")
    static let appBg = Color("app-bg")
    static let appBgOpp = Color("app-bg-opp")
    static let picked = Color.gray.opacity(0.8)
    #if os(iOS)
    static let systemGroupedBackground = Color(UIColor.systemGroupedBackground)
    static let secondarySystemGroupedBackground = Color(UIColor.secondarySystemGroupedBackground)
    #endif
}

#if os(iOS)
extension UIColor {
    static let secondary = UIColor(Color.secondary)
    static let appBg = UIColor(Color.appBg)
    static let mint = UIColor(Color.mint)
    static let picked = UIColor(Color.picked)
}
#endif
