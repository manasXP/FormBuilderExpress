//
//  AppTheme.swift
//  FormBuilderExpress
//
//  Created by Claude on 24/08/25.
//

import SwiftUI

// MARK: - App Theme Configuration
struct AppTheme {
    
    // MARK: - Colors
    struct Colors {
        // Primary gradient colors from Sign in screen
        static let primaryBlue = Color.blue.opacity(0.6)
        static let primaryPurple = Color.purple.opacity(0.8)
        static let primaryPink = Color.pink.opacity(0.6)
        
        // Gradient definitions
        static let backgroundGradient = LinearGradient(
            gradient: Gradient(colors: [primaryBlue, primaryPurple, primaryPink]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let buttonGradient = LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.purple]),
            startPoint: .leading,
            endPoint: .trailing
        )
        
        // Surface colors
        static let cardBackground = Color.white.opacity(0.15)
        static let inputBackground = Color.white
        static let overlayBackground = Color.white.opacity(0.1)
        
        // Text colors
        static let primaryText = Color.white
        static let secondaryText = Color.white.opacity(0.8)
        static let placeholderText = Color.gray
        
        // State colors
        static let errorColor = Color.red
        static let successColor = Color.green
        static let warningColor = Color.orange
        
        // Accent colors for icons
        static let iconBlue = Color.blue
        static let iconGreen = Color.green
        static let iconPurple = Color.purple
        static let iconRed = Color.red
    }
    
    // MARK: - Typography
    struct Typography {
        // Large titles
        static let largeTitle = Font.system(size: 32, weight: .bold, design: .rounded)
        static let title = Font.system(size: 28, weight: .bold)
        static let title2 = Font.system(size: 24, weight: .bold)
        static let title3 = Font.system(size: 20, weight: .semibold)
        
        // Body text
        static let headline = Font.system(size: 18, weight: .semibold)
        static let body = Font.system(size: 16, weight: .medium)
        static let bodySmall = Font.system(size: 14, weight: .medium)
        static let caption = Font.system(size: 12, weight: .medium)
        
        // Button text - increased for better readability
        static let buttonText = Font.system(size: 18, weight: .semibold)
        static let buttonTextSmall = Font.system(size: 16, weight: .semibold)
        
        // Form labels
        static let fieldLabel = Font.system(size: 14, weight: .semibold)
        static let fieldPlaceholder = Font.system(size: 16, weight: .medium)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 40
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let light = Color.black.opacity(0.1)
        static let medium = Color.black.opacity(0.2)
        static let heavy = Color.black.opacity(0.3)
        
        static let cardShadow = Shadow(color: light, radius: 8, x: 0, y: 4)
        static let buttonShadow = Shadow(color: Colors.iconBlue.opacity(0.3), radius: 8, x: 0, y: 4)
        static let errorShadow = Shadow(color: Colors.errorColor.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Shadow Helper
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Theme View Modifiers
extension View {
    func themedBackground() -> some View {
        self
            .background(AppTheme.Colors.backgroundGradient.ignoresSafeArea())
            .overlay(
                // Background blur effects
                GeometryReader { _ in
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 300, height: 300)
                            .blur(radius: 10)
                            .offset(x: -150, y: -200)
                        
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 200, height: 200)
                            .blur(radius: 10)
                            .offset(x: 150, y: 100)
                    }
                }
                .allowsHitTesting(false)
            )
    }
    
    func themedCard() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.extraLarge)
                    .fill(AppTheme.Colors.cardBackground)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.extraLarge)
                            .fill(AppTheme.Colors.overlayBackground)
                            .blur(radius: 10)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.extraLarge)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
    }
    
    func themedButton(isLoading: Bool = false, style: ButtonStyle = .primary) -> some View {
        self
            .frame(height: 50) // Set fixed height to 50px
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    switch style {
                    case .primary:
                        AppTheme.Colors.buttonGradient
                    case .secondary:
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    case .destructive:
                        LinearGradient(
                            gradient: Gradient(colors: [AppTheme.Colors.errorColor]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                }
            )
            .foregroundColor(.white)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .shadow(
                color: {
                    switch style {
                    case .primary: return AppTheme.Colors.iconBlue.opacity(0.3)
                    case .secondary: return Color.gray.opacity(0.3)
                    case .destructive: return AppTheme.Colors.errorColor.opacity(0.3)
                    }
                }(),
                radius: 6, // Slightly reduce shadow radius
                x: 0,
                y: 3 // Reduce shadow offset
            )
            .scaleEffect(isLoading ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isLoading)
    }
    
    func themedTextField() -> some View {
        self
            .padding()
            .background(AppTheme.Colors.inputBackground)
            .cornerRadius(AppTheme.CornerRadius.medium)
            .shadow(color: AppTheme.Shadows.light, radius: 8, x: 0, y: 4)
    }
    
    func themedErrorMessage() -> some View {
        self
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background(AppTheme.Colors.errorColor.opacity(0.1))
            .cornerRadius(AppTheme.CornerRadius.small)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.small)
                    .stroke(AppTheme.Colors.errorColor.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Button Styles
enum ButtonStyle {
    case primary
    case destructive
    case secondary
}

// MARK: - Themed Components
struct ThemedHeaderView: View {
    let title: String
    let subtitle: String?
    let iconName: String
    
    init(title: String, subtitle: String? = nil, iconName: String = "lock.shield") {
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
    }
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .blur(radius: 10)
                    )
                
                Image(systemName: iconName)
                    .font(.system(size: 35))
                    .foregroundColor(.white)
            }
            .padding(.top, 60)
            
            // Title and subtitle
            VStack(spacing: AppTheme.Spacing.xs) {
                Text(title)
                    .font(AppTheme.Typography.largeTitle)
                    .foregroundColor(AppTheme.Colors.primaryText)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(AppTheme.Typography.body)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
            }
        }
    }
}

struct ThemedInputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let iconName: String
    let isRequired: Bool
    
    init(title: String, placeholder: String, text: Binding<String>, iconName: String = "textformat", isRequired: Bool = false) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.iconName = iconName
        self.isRequired = isRequired
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack {
                Text(title)
                    .font(AppTheme.Typography.fieldLabel)
                    .foregroundColor(AppTheme.Colors.placeholderText)
                
                if isRequired {
                    Text("*")
                        .font(AppTheme.Typography.fieldLabel)
                        .foregroundColor(AppTheme.Colors.errorColor)
                }
            }
            
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(AppTheme.Colors.placeholderText)
                    .frame(width: 20)
                
                TextField(placeholder, text: $text)
                    .font(AppTheme.Typography.fieldPlaceholder)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            .themedTextField()
        }
        .accessibleFormField(
            label: title,
            hint: placeholder,
            isRequired: isRequired
        )
    }
}

struct ThemedLoadingIndicator: View {
    let count: Int
    @State private var isAnimating = false
    
    init(count: Int = 3) {
        self.count = count
    }
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(Color.white)
                    .frame(width: 8, height: 8)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}