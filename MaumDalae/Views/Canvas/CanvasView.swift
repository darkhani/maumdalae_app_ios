import SwiftUI
import PencilKit

struct CanvasView: View {
    let persona: UserPersona
    let template: TherapyTemplate
    var existingDrawing: SavedDrawing? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var selectedBrush: BrushStyle = .crayon
    @State private var selectedColor: Color = .brown
    @State private var showSaveAlert = false
    @State private var saveMessage = ""
    @State private var backgroundImage: UIImage?

    private var palette: PersonaPalette { AppTheme.palette(for: persona) }
    private var isEditing: Bool { existingDrawing != nil }

    var body: some View {
        VStack(spacing: 0) {
            promptBanner
            ZStack {
                Color.white
                if let backgroundImage {
                    Image(uiImage: backgroundImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                DrawingCanvasRepresentable(canvasView: $canvasView, toolPicker: toolPicker)
                if !isEditing {
                    TemplateGuideOverlay(templateId: template.id, palette: palette)
                }
            }
            .background(Color.white)
            brushToolbar
            actionBar
        }
        .navigationTitle(isEditing ? "\(template.title) 편집" : template.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { setupCanvas() }
        .alert("저장", isPresented: $showSaveAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(saveMessage)
        }
    }

    private var promptBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isEditing {
                Text("저장된 작품 위에 이어서 그릴 수 있어요.")
                    .font(palette.usesHighContrast ? .title3 : .subheadline)
                    .foregroundStyle(palette.accent)
            }
            Text(template.prompt)
                .font(palette.usesHighContrast ? .title3 : .subheadline)
                .foregroundStyle(palette.text)
            if persona == .petLoss {
                HStack(spacing: 6) {
                    Image(systemName: "cloud.rainbow.half.fill")
                    Text("무지개다리 모티브")
                }
                .font(.caption)
                .foregroundStyle(palette.muted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(palette.card)
    }

    private var brushToolbar: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(BrushStyle.allCases) { brush in
                        Button {
                            selectedBrush = brush
                            applyBrush()
                        } label: {
                            Text(brush.label)
                                .font(palette.usesHighContrast ? .body.weight(.semibold) : .caption.weight(.medium))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(selectedBrush == brush ? palette.primary : palette.primary.opacity(0.12))
                                .foregroundStyle(selectedBrush == brush ? .white : palette.text)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 16)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(BrushPalette.colors(for: persona), id: \.self) { color in
                        Button {
                            selectedColor = color
                            applyBrush()
                        } label: {
                            Circle()
                                .fill(color)
                                .frame(width: persona == .senior ? 44 : 36, height: persona == .senior ? 44 : 36)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == color ? palette.primary : .clear, lineWidth: 3)
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 12)
        .background(palette.background)
    }

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button("지우기") {
                canvasView.drawing = PKDrawing()
            }
            .font(palette.usesHighContrast ? .title3 : .body)
            .foregroundStyle(palette.muted)

            Spacer()

            PrimaryButton(
                title: isEditing ? "변경 사항 저장" : "작품 저장",
                palette: palette,
                icon: "square.and.arrow.down"
            ) {
                saveDrawing()
            }
            .frame(maxWidth: 180)
        }
        .padding(16)
        .background(palette.card)
    }

    private func setupCanvas() {
        if let existingDrawing,
           let image = LocalStorageService.loadImage(fileName: existingDrawing.fileName) {
            backgroundImage = image
        }
        canvasView.drawingPolicy = .anyInput
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.drawing = PKDrawing()
        canvasView.tool = selectedBrush.tool(color: UIColor(selectedColor))
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }

    private func applyBrush() {
        canvasView.tool = selectedBrush.tool(color: UIColor(selectedColor))
    }

    private func saveDrawing() {
        let bounds = canvasView.bounds
        guard bounds.width > 0, bounds.height > 0 else {
            saveMessage = "캔버스가 준비되지 않았습니다. 잠시 후 다시 시도해 주세요."
            showSaveAlert = true
            return
        }

        let scale = UIScreen.main.scale
        let strokeImage = canvasView.drawing.image(from: bounds, scale: scale)
        let finalImage = DrawingImageUtilities.compositeOnWhite(
            background: backgroundImage,
            strokes: strokeImage,
            size: bounds.size,
            scale: scale
        )

        do {
            if let existing = existingDrawing {
                _ = try LocalStorageService.saveDrawing(
                    finalImage,
                    id: existing.id,
                    fileName: existing.fileName
                )
                let updated = SavedDrawing(
                    id: existing.id,
                    persona: existing.persona,
                    title: existing.title,
                    fileName: existing.fileName,
                    createdAt: Date()
                )
                LocalStorageService.updateDrawing(updated)
                backgroundImage = finalImage
                canvasView.drawing = PKDrawing()
                saveMessage = "작품이 업데이트되었습니다."
            } else {
                let id = UUID()
                let fileName = try LocalStorageService.saveDrawing(finalImage, id: id)
                let saved = SavedDrawing(
                    id: id,
                    persona: persona,
                    title: template.title,
                    fileName: fileName,
                    createdAt: Date()
                )
                LocalStorageService.appendDrawing(saved)
                saveMessage = "갤러리에 저장되었습니다."
            }
            showSaveAlert = true
        } catch {
            saveMessage = "저장에 실패했습니다. 다시 시도해 주세요."
            showSaveAlert = true
        }
    }

}

enum BrushStyle: String, CaseIterable, Identifiable {
    case pencil, crayon, watercolor, marker

    var id: String { rawValue }

    var label: String {
        switch self {
        case .pencil: return "연필"
        case .crayon: return "크레파스"
        case .watercolor: return "수채"
        case .marker: return "마커"
        }
    }

    func tool(color: UIColor) -> PKInkingTool {
        switch self {
        case .pencil:
            return PKInkingTool(.pencil, color: color, width: 3)
        case .crayon:
            return PKInkingTool(.pen, color: color, width: 8)
        case .watercolor:
            return PKInkingTool(.marker, color: color.withAlphaComponent(0.45), width: 18)
        case .marker:
            return PKInkingTool(.marker, color: color, width: 12)
        }
    }
}

enum BrushPalette {
    static func colors(for persona: UserPersona) -> [Color] {
        switch persona {
        case .petLoss:
            return [.init(red: 0.78, green: 0.65, blue: 0.82), .init(red: 0.55, green: 0.72, blue: 0.68),
                    .init(red: 0.95, green: 0.75, blue: 0.78), .init(red: 0.55, green: 0.48, blue: 0.78),
                    .brown, .gray]
        case .senior:
            return [.black, .blue, .green, .orange, .red, .purple, .brown]
        }
    }
}

struct TemplateGuideOverlay: View {
    let templateId: String
    let palette: PersonaPalette

    var body: some View {
        GeometryReader { geo in
            let color = palette.primary.opacity(0.28)
            switch templateId {
            case "rainbow_bridge":
                Path { path in
                    path.move(to: CGPoint(x: geo.size.width * 0.15, y: geo.size.height * 0.55))
                    path.addQuadCurve(
                        to: CGPoint(x: geo.size.width * 0.85, y: geo.size.height * 0.55),
                        control: CGPoint(x: geo.size.width * 0.5, y: geo.size.height * 0.2)
                    )
                }
                .stroke(color, style: StrokeStyle(lineWidth: 4, dash: [8, 8]))
            case "memory_paw", "hometown", "young_days":
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color, style: StrokeStyle(lineWidth: 3, dash: [10, 8]))
                    .padding(.horizontal, geo.size.width * 0.2)
                    .padding(.vertical, geo.size.height * 0.25)
            default:
                EmptyView()
            }
        }
        .allowsHitTesting(false)
    }
}

struct DrawingCanvasRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    let toolPicker: PKToolPicker

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.isOpaque = false
        uiView.backgroundColor = .clear
    }
}
