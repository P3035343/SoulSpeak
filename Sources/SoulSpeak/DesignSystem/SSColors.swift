import SwiftUI

enum SSColors {
    static let primary = Color(red: 0.4, green: 0.3, blue: 0.8)
    static let secondary = Color(red: 0.6, green: 0.4, blue: 0.9)
    static let accent = Color(red: 0.5, green: 0.7, blue: 1.0)
    static let background = Color(red: 0.97, green: 0.97, blue: 0.98)
    static let surface = Color.white
    static let textPrimary = Color(red: 0.1, green: 0.1, blue: 0.15)
    static let textSecondary = Color(red: 0.4, green: 0.4, blue: 0.5)
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let calm = Color(red: 0.6, green: 0.8, blue: 0.9)
    static let energy = Color(red: 1.0, green: 0.7, blue: 0.3)
    static let growth = Color(red: 0.4, green: 0.8, blue: 0.5)
    static let love = Color(red: 0.9, green: 0.4, blue: 0.5)
    
    static let gradientPrimary = LinearGradient(
        colors: [Color(red: 0.4, green: 0.3, blue: 0.8), Color(red: 0.6, green: 0.4, blue: 0.9)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let gradientCalm = LinearGradient(
        colors: [Color(red: 0.3, green: 0.6, blue: 0.8), Color(red: 0.5, green: 0.8, blue: 0.9)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let gradientWarm = LinearGradient(
        colors: [Color(red: 0.9, green: 0.5, blue: 0.3), Color(red: 1.0, green: 0.7, blue: 0.4)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
