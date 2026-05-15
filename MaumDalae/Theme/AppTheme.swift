import SwiftUI

enum AppTheme {
    static func palette(for persona: UserPersona) -> PersonaPalette {
        switch persona {
        case .petLoss:
            return PersonaPalette(
                background: Color(red: 0.97, green: 0.95, blue: 0.99),
                card: Color.white.opacity(0.92),
                primary: Color(red: 0.55, green: 0.48, blue: 0.78),
                secondary: Color(red: 0.78, green: 0.65, blue: 0.82),
                accent: Color(red: 0.45, green: 0.72, blue: 0.68),
                text: Color(red: 0.28, green: 0.25, blue: 0.35),
                muted: Color(red: 0.5, green: 0.47, blue: 0.58),
                titleFont: .title2,
                bodyFont: .body,
                buttonMinHeight: 52,
                cornerRadius: 20,
                usesHighContrast: false
            )
        case .senior:
            return PersonaPalette(
                background: Color(red: 0.98, green: 0.98, blue: 0.96),
                card: Color.white,
                primary: Color(red: 0.12, green: 0.35, blue: 0.62),
                secondary: Color(red: 0.85, green: 0.55, blue: 0.15),
                accent: Color(red: 0.15, green: 0.55, blue: 0.35),
                text: Color.black,
                muted: Color(red: 0.25, green: 0.25, blue: 0.25),
                titleFont: .largeTitle,
                bodyFont: .title3,
                buttonMinHeight: 64,
                cornerRadius: 16,
                usesHighContrast: true
            )
        }
    }
}

struct PersonaPalette {
    let background: Color
    let card: Color
    let primary: Color
    let secondary: Color
    let accent: Color
    let text: Color
    let muted: Color
    let titleFont: Font
    let bodyFont: Font
    let buttonMinHeight: CGFloat
    let cornerRadius: CGFloat
    let usesHighContrast: Bool
}

struct PersonaThemeModifier: ViewModifier {
    let persona: UserPersona

    func body(content: Content) -> some View {
        let palette = AppTheme.palette(for: persona)
        content
            .font(palette.bodyFont)
            .foregroundStyle(palette.text)
            .background(palette.background.ignoresSafeArea())
    }
}

extension View {
    func personaTheme(_ persona: UserPersona) -> some View {
        modifier(PersonaThemeModifier(persona: persona))
    }
}
