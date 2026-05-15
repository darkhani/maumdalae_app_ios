import SwiftUI

struct PrimaryButton: View {
    let title: String
    let palette: PersonaPalette
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon {
                    Image(systemName: icon)
                        .font(palette.usesHighContrast ? .title2 : .body)
                }
                Text(title)
                    .font(palette.usesHighContrast ? .title2.weight(.semibold) : .headline)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: palette.buttonMinHeight)
            .foregroundStyle(.white)
            .background(palette.primary)
            .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
    }
}

struct SecondaryCardButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let palette: PersonaPalette
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: palette.usesHighContrast ? 36 : 28))
                    .foregroundStyle(palette.primary)
                    .frame(width: 56, height: 56)
                    .background(palette.primary.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(palette.usesHighContrast ? .title2.weight(.bold) : .headline)
                        .foregroundStyle(palette.text)
                    Text(subtitle)
                        .font(palette.usesHighContrast ? .title3 : .subheadline)
                        .foregroundStyle(palette.muted)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .foregroundStyle(palette.muted)
            }
            .padding(20)
            .background(palette.card)
            .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
            .shadow(color: .black.opacity(palette.usesHighContrast ? 0.08 : 0.04), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}
