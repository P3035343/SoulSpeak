import SwiftUI

enum SSButtonStyle {
    case primary
    case secondary
    case outline
    case ghost
    case destructive
}

struct SSButton: View {
    let title: String
    let style: SSButtonStyle
    let icon: String?
    let isLoading: Bool
    let action: () -> Void
    
    init(
        title: String,
        style: SSButtonStyle = .primary,
        icon: String? = nil,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.icon = icon
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(textColor)
                        .scaleEffect(0.8)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Text(title)
                        .font(SSTypography.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: style == .outline ? 2 : 0)
            )
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.7 : 1.0)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary: return SSColors.primary
        case .secondary: return SSColors.secondary
        case .outline: return .clear
        case .ghost: return .clear
        case .destructive: return SSColors.error
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return .white
        case .outline: return SSColors.primary
        case .ghost: return SSColors.primary
        case .destructive: return .white
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .outline: return SSColors.primary
        default: return .clear
        }
    }
}
