import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            if appState.hasCompletedOnboarding, let persona = appState.selectedPersona {
                MainTabView(persona: persona)
            } else {
                PersonaSelectionView()
            }
        }
        .animation(.easeInOut, value: appState.hasCompletedOnboarding)
    }
}
