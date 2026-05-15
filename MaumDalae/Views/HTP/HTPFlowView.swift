import SwiftUI

struct HTPFlowView: View {
    let persona: UserPersona
    @State private var step: HTPStep = .disclaimer
    @State private var acceptedDisclaimer = false
    @State private var capturedImage: UIImage?
    @State private var analysis: HTPAnalysis?
    @State private var isAnalyzing = false

    private var palette: PersonaPalette { AppTheme.palette(for: persona) }

    enum HTPStep {
        case disclaimer, guide, camera, analyzing, result
    }

    var body: some View {
        Group {
            switch step {
            case .disclaimer:
                HTPDisclaimerView(
                    palette: palette,
                    accepted: $acceptedDisclaimer
                ) {
                    step = .guide
                }
            case .guide:
                HTPGuideView(palette: palette) {
                    step = .camera
                }
            case .camera:
                HTPCameraView(palette: palette) { image in
                    capturedImage = image
                    step = .analyzing
                    runAnalysis(image)
                }
            case .analyzing:
                HTPAnalyzingView(palette: palette)
            case .result:
                if let analysis, let image = capturedImage {
                    HTPResultView(
                        persona: persona,
                        analysis: analysis,
                        image: image,
                        onStartSession: { /* Navigation handled by parent dismiss + home */ }
                    )
                }
            }
        }
        .navigationTitle("HTP 검사")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func runAnalysis(_ image: UIImage) {
        isAnalyzing = true
        Task {
            let result = await HTPAnalysisService.analyze(image: image, persona: persona)
            await MainActor.run {
                analysis = result
                LocalStorageService.appendHTP(result)
                isAnalyzing = false
                step = .result
            }
        }
    }
}

struct HTPDisclaimerView: View {
    let palette: PersonaPalette
    @Binding var accepted: Bool
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Label("안내 및 면책", systemImage: "exclamationmark.shield.fill")
                    .font(palette.usesHighContrast ? .title.weight(.bold) : .title2.weight(.semibold))
                    .foregroundStyle(palette.primary)

                Text(TherapyContentProvider.htpDisclaimer)
                    .font(palette.bodyFont)
                    .foregroundStyle(palette.text)

                Toggle(isOn: $accepted) {
                    Text("위 내용을 이해했습니다")
                        .font(palette.usesHighContrast ? .title3 : .body)
                }
                .tint(palette.primary)

                PrimaryButton(
                    title: "다음",
                    palette: palette,
                    icon: "arrow.right"
                ) {
                    onContinue()
                }
                .disabled(!accepted)
                .opacity(accepted ? 1 : 0.5)
            }
            .padding(24)
        }
        .background(palette.background)
    }
}

struct HTPGuideView: View {
    let palette: PersonaPalette
    let onStart: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("촬영 전 준비")
                    .font(palette.usesHighContrast ? .largeTitle.weight(.bold) : .title2.weight(.semibold))

                guideRow(icon: "doc.richtext", text: "A4 용지에 집, 나무, 사람을 그려 주세요.")
                guideRow(icon: "light.max", text: "밝은 곳에서 그림 전체가 보이게 촬영해 주세요.")
                guideRow(icon: "level.fill", text: "촬영 시 수평 가이드를 맞춰 주세요.")
                guideRow(icon: "hand.raised.fill", text: "그림자가 그림 위에 지지 않게 해 주세요.")

                PrimaryButton(title: "촬영 시작", palette: palette, icon: "camera.fill", action: onStart)
            }
            .padding(24)
        }
        .background(palette.background)
    }

    private func guideRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(palette.usesHighContrast ? .title2 : .title3)
                .foregroundStyle(palette.accent)
                .frame(width: 32)
            Text(text)
                .font(palette.bodyFont)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(palette.card)
        .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
    }
}

struct HTPAnalyzingView: View {
    let palette: PersonaPalette

    var body: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(palette.usesHighContrast ? 2 : 1.5)
            Text("마음의 그림을 살펴보고 있어요…")
                .font(palette.usesHighContrast ? .title2 : .headline)
                .foregroundStyle(palette.muted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(palette.background)
    }
}
