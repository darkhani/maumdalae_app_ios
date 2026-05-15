import SwiftUI

struct HTPResultView: View {
    let persona: UserPersona
    let analysis: HTPAnalysis
    let image: UIImage
    let onStartSession: () -> Void

    @State private var showCrisisSheet = false
    @Environment(\.dismiss) private var dismiss

    private var palette: PersonaPalette { AppTheme.palette(for: persona) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
                    .shadow(radius: 6, y: 3)

                resultCard(
                    title: "마음의 메시지",
                    body: analysis.healingMessage,
                    icon: "heart.text.square.fill"
                )

                resultCard(
                    title: "추천 세션",
                    body: analysis.recommendation,
                    icon: "sparkles"
                )

                structuralSection

                PrimaryButton(
                    title: recommendedSessionTitle,
                    palette: palette,
                    icon: "paintbrush.fill"
                ) {
                    dismiss()
                }
            }
            .padding(24)
        }
        .background(palette.background)
        .navigationBarBackButtonHidden(analysis.showsCrisisAlert)
        .onAppear {
            if analysis.showsCrisisAlert {
                showCrisisSheet = true
            }
        }
        .sheet(isPresented: $showCrisisSheet) {
            CrisisInterventionSheet(palette: palette)
        }
    }

    private var recommendedSessionTitle: String {
        persona == .senior ? "회상 컬러링 시작" : "치유 캔버스 시작"
    }

    private func resultCard(title: String, body: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(palette.usesHighContrast ? .title2.weight(.bold) : .headline)
                .foregroundStyle(palette.primary)
            Text(body)
                .font(palette.bodyFont)
                .foregroundStyle(palette.text)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(palette.card)
        .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
    }

    private var structuralSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("표현 특성 (참고)")
                .font(palette.usesHighContrast ? .title3.weight(.bold) : .subheadline.weight(.semibold))

            featureRow("위치", analysis.structuralFeatures.position)
            featureRow("필압", analysis.structuralFeatures.pressure)
            featureRow("선", analysis.structuralFeatures.lineQuality)

            ForEach(Array(analysis.detectedObjects.keys.sorted()), id: \.self) { key in
                if let value = analysis.detectedObjects[key] {
                    featureRow(keyLabel(key), value)
                }
            }
        }
        .padding(18)
        .background(palette.primary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
    }

    private func featureRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(palette.muted)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
        .font(palette.usesHighContrast ? .body : .subheadline)
    }

    private func keyLabel(_ key: String) -> String {
        switch key {
        case "house": return "집"
        case "tree": return "나무"
        case "person": return "사람"
        default: return key
        }
    }
}

struct CrisisInterventionSheet: View {
    let palette: PersonaPalette
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "phone.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.red)

                Text("지금 많이 힘드실 수 있어요")
                    .font(palette.usesHighContrast ? .title.weight(.bold) : .title2.weight(.semibold))
                    .multilineTextAlignment(.center)

                Text("혼자 견디지 않으셔도 됩니다. 전문 상담사와 이야기해 보세요.")
                    .font(palette.bodyFont)
                    .foregroundStyle(palette.muted)
                    .multilineTextAlignment(.center)

                if let url = URL(string: "tel://1393") {
                    Link(destination: url) {
                        HStack(spacing: 12) {
                            Image(systemName: "phone.fill")
                            Text(TherapyContentProvider.crisisHotlineLabel)
                                .font(palette.usesHighContrast ? .title2.weight(.semibold) : .headline)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: palette.buttonMinHeight)
                        .foregroundStyle(.white)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
                    }
                }

                Button("닫기") { dismiss() }
                    .font(palette.bodyFont)
                    .foregroundStyle(palette.muted)
            }
            .padding(28)
            .navigationTitle("도움 요청")
            .navigationBarTitleDisplayMode(.inline)
        }
        .interactiveDismissDisabled()
    }
}
