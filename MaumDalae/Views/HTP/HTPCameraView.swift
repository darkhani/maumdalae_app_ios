import SwiftUI
import PhotosUI

struct HTPCameraView: View {
    let palette: PersonaPalette
    let onCapture: (UIImage) -> Void

    @StateObject private var levelGuide = LevelGuideManager()
    @State private var showPicker = false
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 20) {
            levelIndicator

            ZStack {
                RoundedRectangle(cornerRadius: palette.cornerRadius)
                    .stroke(palette.primary, lineWidth: 3)
                    .aspectRatio(210 / 297, contentMode: .fit)
                    .padding(.horizontal, 24)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "doc.viewfinder")
                                .font(.system(size: 48))
                                .foregroundStyle(palette.primary.opacity(0.5))
                            Text("A4 용지를 이 안에 맞춰 주세요")
                                .font(palette.usesHighContrast ? .title3 : .subheadline)
                                .foregroundStyle(palette.muted)
                                .multilineTextAlignment(.center)
                        }
                    }

                cornerGuides
            }

            Text(levelGuide.isLevel ? "수평이 맞았어요" : "기기를 좌우로 기울여 수평을 맞춰 주세요")
                .font(palette.usesHighContrast ? .title3.weight(.semibold) : .body)
                .foregroundStyle(levelGuide.isLevel ? palette.accent : palette.secondary)

            VStack(spacing: 12) {
                PrimaryButton(title: "사진 촬영", palette: palette, icon: "camera.fill") {
                    showPicker = true
                }

                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Text("앨범에서 선택")
                        .font(palette.usesHighContrast ? .title3 : .body)
                        .foregroundStyle(palette.primary)
                        .frame(maxWidth: .infinity, minHeight: palette.buttonMinHeight - 8)
                        .background(palette.card)
                        .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 20)
        .background(palette.background)
        .onAppear { levelGuide.start() }
        .onDisappear { levelGuide.stop() }
        .fullScreenCover(isPresented: $showPicker) {
            ImagePicker(sourceType: .camera) { image in
                showPicker = false
                if let image {
                    onCapture(image)
                }
            }
            .ignoresSafeArea()
        }
        .onChange(of: selectedItem) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    onCapture(image)
                }
            }
        }
    }

    private var levelIndicator: some View {
        HStack(spacing: 12) {
            Image(systemName: levelGuide.isLevel ? "level.fill" : "level")
                .foregroundStyle(levelGuide.isLevel ? palette.accent : palette.muted)
            GeometryReader { geo in
                ZStack(alignment: .center) {
                    Capsule()
                        .fill(palette.muted.opacity(0.2))
                    Circle()
                        .fill(levelGuide.isLevel ? palette.accent : palette.secondary)
                        .frame(width: 20, height: 20)
                        .offset(x: CGFloat(levelGuide.rollDegrees / 15) * (geo.size.width / 2 - 12))
                }
            }
            .frame(height: 24)
        }
        .padding(.horizontal, 24)
    }

    private var cornerGuides: some View {
        GeometryReader { geo in
            let inset: CGFloat = 24
            let w = geo.size.width - inset * 2
            let h = w * 297 / 210
            let rect = CGRect(x: inset, y: (geo.size.height - h) / 2, width: w, height: h)
            Path { path in
                let len: CGFloat = 24
                path.move(to: CGPoint(x: rect.minX, y: rect.minY + len))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.minX + len, y: rect.minY))
                path.move(to: CGPoint(x: rect.maxX - len, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + len))
                path.move(to: CGPoint(x: rect.minX, y: rect.maxY - len))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.minX + len, y: rect.maxY))
                path.move(to: CGPoint(x: rect.maxX - len, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - len))
            }
            .stroke(palette.accent, lineWidth: 3)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onComplete: (UIImage?) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete, dismiss: dismiss)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onComplete: (UIImage?) -> Void
        let dismiss: DismissAction

        init(onComplete: @escaping (UIImage?) -> Void, dismiss: DismissAction) {
            self.onComplete = onComplete
            self.dismiss = dismiss
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
            onComplete(nil)
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let image = info[.originalImage] as? UIImage
            dismiss()
            onComplete(image)
        }
    }
}
