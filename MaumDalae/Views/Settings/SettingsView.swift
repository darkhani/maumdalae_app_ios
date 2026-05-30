import SwiftUI
import AVFoundation

struct SettingsView: View {
    let persona: UserPersona
    @EnvironmentObject private var appState: AppState
    @AppStorage("maumdalae.voiceGuide") private var voiceGuideEnabled = false
    private let synthesizer = AVSpeechSynthesizer()

    private var palette: PersonaPalette { AppTheme.palette(for: persona) }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle(isOn: $voiceGuideEnabled) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("음성 안내 (TTS)")
                                .font(palette.usesHighContrast ? .title3 : .body)
                            Text("버튼과 안내 문구를 읽어 드립니다")
                                .font(.caption)
                                .foregroundStyle(palette.muted)
                        }
                    }
                    .tint(palette.primary)
                    .onChange(of: voiceGuideEnabled) { _, enabled in
                        if enabled {
                            speak("음성 안내가 켜졌습니다.")
                        }
                    }

                    Button("음성 테스트") {
                        speak("마음달래에 오신 것을 환영합니다. 천천히, 편안하게 시작해 보세요.")
                    }
                } header: {
                    Text("접근성")
                }

                Section {
                    LabeledContent("선택한 여정", value: persona.title)
                    LabeledContent("세션 유형", value: persona.sessionTitle)
                } header: {
                    Text("내 프로필")
                }

                Section {
                    Button("여정 다시 선택", role: .destructive) {
                        appState.resetOnboarding()
                    }
                }
            }
            .font(palette.usesHighContrast ? .title3 : .body)
            .navigationTitle("설정")
        }
    }

    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        utterance.rate = persona == .senior ? 0.42 : 0.48
        synthesizer.speak(utterance)
    }
}
