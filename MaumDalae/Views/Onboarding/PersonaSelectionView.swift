import SwiftUI

struct PersonaSelectionView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selected: UserPersona?

    private let palette = AppTheme.palette(for: .petLoss)

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(spacing: 12) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(palette.primary)
                    Text("마음달래")
                        .font(.largeTitle.bold())
                    Text("미술로 마음을 돌보는 공간")
                        .font(.title3)
                        .foregroundStyle(palette.muted)
                }
                .padding(.top, 40)

                Text("어떤 여정을 시작하시겠어요?")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(UserPersona.allCases) { persona in
                    PersonaCard(
                        persona: persona,
                        isSelected: selected == persona,
                        palette: AppTheme.palette(for: persona)
                    ) {
                        selected = persona
                    }
                }

                if let selected {
                    PrimaryButton(
                        title: "\(selected.title) 시작하기",
                        palette: AppTheme.palette(for: selected),
                        icon: "arrow.right.circle.fill"
                    ) {
                        appState.completeOnboarding(with: selected)
                    }
                    .padding(.top, 8)
                }
            }
            .padding(24)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.94, blue: 0.99),
                    Color(red: 0.94, green: 0.97, blue: 0.96)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}

private struct PersonaCard: View {
    let persona: UserPersona
    let isSelected: Bool
    let palette: PersonaPalette
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: persona == .petLoss ? "pawprint.fill" : "photo.on.rectangle.angled")
                        .font(.title)
                        .foregroundStyle(palette.primary)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(palette.accent)
                            .font(.title2)
                    }
                }
                Text(persona.title)
                    .font(.title2.bold())
                    .foregroundStyle(palette.text)
                Text(persona.subtitle)
                    .font(.body)
                    .foregroundStyle(palette.muted)
                    .multilineTextAlignment(.leading)
                Text(persona.sessionTitle)
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(palette.secondary.opacity(0.25))
                    .clipShape(Capsule())
            }
            .padding(20)
            .background(palette.card)
            .overlay(
                RoundedRectangle(cornerRadius: palette.cornerRadius)
                    .stroke(isSelected ? palette.primary : .clear, lineWidth: 3)
            )
            .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
        }
        .buttonStyle(.plain)
    }
}
