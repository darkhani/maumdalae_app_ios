import SwiftUI

struct HomeView: View {
    let persona: UserPersona
    @State private var showCanvas = false
    @State private var showHTP = false
    @State private var selectedTemplate: TherapyTemplate?

    private var palette: PersonaPalette { AppTheme.palette(for: persona) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    quickActions
                    templateSection
                    voiceGuideCard
                }
                .padding(20)
            }
            .background(palette.background)
            .navigationTitle(persona.title)
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(isPresented: $showCanvas) {
                if let template = selectedTemplate {
                    CanvasView(persona: persona, template: template)
                } else {
                    CanvasView(
                        persona: persona,
                        template: TherapyContentProvider.templates(for: persona).first!
                    )
                }
            }
            .navigationDestination(isPresented: $showHTP) {
                HTPFlowView(persona: persona)
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(greeting)
                .font(palette.usesHighContrast ? .title.weight(.bold) : .title2.weight(.semibold))
            Text(persona.subtitle)
                .font(palette.bodyFont)
                .foregroundStyle(palette.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                colors: [palette.primary.opacity(0.15), palette.accent.opacity(0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
    }

    private var greeting: String {
        switch persona {
        case .petLoss: return "오늘도 소중한 기억을 함께해요"
        case .senior: return "오늘 하루도 수고 많으셨어요"
        }
    }

    private var quickActions: some View {
        VStack(spacing: 14) {
            Text("바로 시작하기")
                .font(palette.usesHighContrast ? .title2.weight(.bold) : .headline)

            SecondaryCardButton(
                title: "디지털 캔버스",
                subtitle: "따뜻한 붓·크레파스로 마음을 그려요",
                icon: "paintbrush.pointed.fill",
                palette: palette
            ) {
                selectedTemplate = TherapyContentProvider.templates(for: persona).first
                showCanvas = true
            }

            SecondaryCardButton(
                title: "HTP 그림 검사",
                subtitle: "A4에 그린 집·나무·사람을 분석해요",
                icon: "camera.viewfinder",
                palette: palette
            ) {
                showHTP = true
            }
        }
    }

    private var templateSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("가이드 세션")
                .font(palette.usesHighContrast ? .title2.weight(.bold) : .headline)

            ForEach(TherapyContentProvider.templates(for: persona)) { template in
                Button {
                    selectedTemplate = template
                    showCanvas = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(template.title)
                                .font(palette.usesHighContrast ? .title3.weight(.semibold) : .subheadline.weight(.semibold))
                                .foregroundStyle(palette.text)
                            Text(template.prompt)
                                .font(palette.usesHighContrast ? .body : .caption)
                                .foregroundStyle(palette.muted)
                                .lineLimit(2)
                        }
                        Spacer()
                        Image(systemName: "paintpalette.fill")
                            .foregroundStyle(palette.accent)
                    }
                    .padding(16)
                    .background(palette.card)
                    .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius - 4))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var voiceGuideCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "waveform.circle.fill")
                .font(.largeTitle)
                .foregroundStyle(palette.secondary)
            VStack(alignment: .leading, spacing: 4) {
                Text("음성 안내")
                    .font(palette.usesHighContrast ? .title3.weight(.bold) : .subheadline.weight(.semibold))
                Text("글씨 읽기가 어려우시면 설정에서 음성 안내를 켜 주세요.")
                    .font(palette.usesHighContrast ? .body : .caption)
                    .foregroundStyle(palette.muted)
            }
        }
        .padding(16)
        .background(palette.card)
        .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
    }
}
