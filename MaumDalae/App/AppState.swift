import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var selectedPersona: UserPersona?
    @Published var hasCompletedOnboarding: Bool

    private let personaKey = "maumdalae.selectedPersona"
    private let onboardingKey = "maumdalae.onboardingComplete"

    init() {
        if let raw = UserDefaults.standard.string(forKey: personaKey),
           let persona = UserPersona(rawValue: raw) {
            selectedPersona = persona
        }
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
    }

    func completeOnboarding(with persona: UserPersona) {
        selectedPersona = persona
        hasCompletedOnboarding = true
        UserDefaults.standard.set(persona.rawValue, forKey: personaKey)
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }

    func resetOnboarding() {
        selectedPersona = nil
        hasCompletedOnboarding = false
        UserDefaults.standard.removeObject(forKey: personaKey)
        UserDefaults.standard.set(false, forKey: onboardingKey)
    }
}
