//
//  AccessibilityUtils.swift
//  FormBuilderExpress
//
//  Created by Claude on 22/08/25.
//

import SwiftUI

// MARK: - Accessibility Extensions
extension View {
    // Add comprehensive accessibility support
    func accessibleTextField(
        label: String,
        hint: String? = nil,
        isRequired: Bool = false,
        value: String? = nil
    ) -> some View {
        self
            .accessibilityLabel(isRequired ? "\(label), required field" : label)
            .accessibilityHint(hint ?? "")
            .accessibilityValue(value ?? "")
    }
    
    func accessibleButton(
        label: String,
        hint: String? = nil,
        isEnabled: Bool = true
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
            .disabled(!isEnabled)
    }
    
    func accessibleFormSection(
        header: String,
        description: String? = nil
    ) -> some View {
        self
            .accessibilityElement(children: .contain)
            .accessibilityLabel(header)
            .accessibilityHint(description ?? "")
    }
    
    // Support for Dynamic Type scaling
    func scaledFont(
        _ style: Font.TextStyle,
        size: CGFloat? = nil,
        weight: Font.Weight = .regular,
        design: Font.Design = .default
    ) -> some View {
        let uiTextStyle: UIFont.TextStyle
        switch style {
        case .largeTitle: uiTextStyle = .largeTitle
        case .title: uiTextStyle = .title1
        case .title2: uiTextStyle = .title2
        case .title3: uiTextStyle = .title3
        case .headline: uiTextStyle = .headline
        case .subheadline: uiTextStyle = .subheadline
        case .body: uiTextStyle = .body
        case .callout: uiTextStyle = .callout
        case .footnote: uiTextStyle = .footnote
        case .caption: uiTextStyle = .caption1
        case .caption2: uiTextStyle = .caption2
        @unknown default: uiTextStyle = .body
        }
        
        return self.font(
            .system(
                size: size ?? UIFont.preferredFont(forTextStyle: uiTextStyle).pointSize,
                weight: weight,
                design: design
            )
        )
    }
    
    // High contrast support
    func adaptiveColors(
        foreground: Color = .primary,
        background: Color = .clear
    ) -> some View {
        self
            .foregroundColor(foreground)
            .background(background)
    }
}

// MARK: - VoiceOver Announcements
struct AccessibilityManager {
    
    static func announceFormStep(_ step: String, of totalSteps: Int, currentStep: Int) {
        let announcement = "Step \(currentStep) of \(totalSteps): \(step)"
        UIAccessibility.post(notification: .screenChanged, argument: announcement)
    }
    
    static func announceValidation(isValid: Bool, fieldName: String) {
        let announcement = isValid ? 
            "\(fieldName) is valid" : 
            "\(fieldName) contains errors, please review"
        UIAccessibility.post(notification: .announcement, argument: announcement)
    }
    
    static func announceFormSaved() {
        UIAccessibility.post(notification: .announcement, argument: "Form has been automatically saved")
    }
    
    static func announceFormSubmitted() {
        UIAccessibility.post(notification: .announcement, argument: "Form submitted successfully")
    }
    
    static func announceError(_ error: String) {
        UIAccessibility.post(notification: .announcement, argument: "Error: \(error)")
    }
}

// MARK: - Dynamic Type Scaling
struct ScaledFont: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory
    var textStyle: Font.TextStyle
    var maxSize: CGFloat?
    
    func body(content: Content) -> some View {
        let uiTextStyle: UIFont.TextStyle
        switch textStyle {
        case .largeTitle: uiTextStyle = .largeTitle
        case .title: uiTextStyle = .title1
        case .title2: uiTextStyle = .title2
        case .title3: uiTextStyle = .title3
        case .headline: uiTextStyle = .headline
        case .subheadline: uiTextStyle = .subheadline
        case .body: uiTextStyle = .body
        case .callout: uiTextStyle = .callout
        case .footnote: uiTextStyle = .footnote
        case .caption: uiTextStyle = .caption1
        case .caption2: uiTextStyle = .caption2
        @unknown default: uiTextStyle = .body
        }
        
        let scaledSize = UIFontMetrics(forTextStyle: uiTextStyle)
            .scaledValue(for: UIFont.preferredFont(forTextStyle: uiTextStyle).pointSize)
        
        let finalSize = maxSize != nil ? min(scaledSize, maxSize!) : scaledSize
        
        return content.font(.system(size: finalSize))
    }
}

extension View {
    func scaledFont(_ textStyle: Font.TextStyle, maxSize: CGFloat? = nil) -> some View {
        self.modifier(ScaledFont(textStyle: textStyle, maxSize: maxSize))
    }
}

// MARK: - High Contrast Support
struct HighContrastModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.colorSchemeContrast) var contrast
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(contrast == .increased ? 
                (colorScheme == .dark ? .white : .black) : 
                .primary)
    }
}

extension View {
    func highContrastAdaptive() -> some View {
        self.modifier(HighContrastModifier())
    }
}

// MARK: - Focus Management
// Simplified accessibility helpers without complex focus state management
extension View {
    func accessibleFormField(
        label: String,
        hint: String? = nil,
        isRequired: Bool = false,
        isValid: Bool = true
    ) -> some View {
        self
            .accessibilityLabel(isRequired ? "\(label), required field" : label)
            .accessibilityHint(hint ?? "")
    }
}

// MARK: - Navigation Accessibility
struct AccessibleNavigationButton: ViewModifier {
    let action: String
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        content
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel(action)
            .accessibilityHint(isEnabled ? "Double tap to \(action.lowercased())" : "Button is disabled")
            .disabled(!isEnabled)
    }
}

extension View {
    func accessibleNavigation(action: String, isEnabled: Bool = true) -> some View {
        self.modifier(AccessibleNavigationButton(action: action, isEnabled: isEnabled))
    }
}