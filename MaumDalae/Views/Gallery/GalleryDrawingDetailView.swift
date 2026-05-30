import SwiftUI

struct GalleryDrawingDetailView: View {
    let drawing: SavedDrawing
    let persona: UserPersona
    var onChange: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var image: UIImage?
    @State private var showDeleteConfirm = false
    @State private var navigateToEdit = false

    private var palette: PersonaPalette { AppTheme.palette(for: persona) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 280)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(drawing.title)
                        .font(palette.usesHighContrast ? .title.weight(.bold) : .title2.weight(.semibold))
                    Text(drawing.createdAt.formatted(date: .long, time: .shortened))
                        .font(palette.bodyFont)
                        .foregroundStyle(palette.muted)
                }

                PrimaryButton(title: "이어서 편집하기", palette: palette, icon: "paintbrush.fill") {
                    navigateToEdit = true
                }

                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("작품 삭제")
                    }
                    .font(palette.usesHighContrast ? .title3 : .body)
                    .frame(maxWidth: .infinity, minHeight: palette.buttonMinHeight - 8)
                }
            }
            .padding(20)
        }
        .background(palette.background)
        .navigationTitle("작품 보기")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { reloadImage() }
        .navigationDestination(isPresented: $navigateToEdit) {
            CanvasView(
                persona: persona,
                template: TherapyContentProvider.template(forTitle: drawing.title, persona: persona),
                existingDrawing: drawing
            )
        }
        .alert("작품 삭제", isPresented: $showDeleteConfirm) {
            Button("삭제", role: .destructive) {
                LocalStorageService.deleteDrawing(id: drawing.id)
                onChange()
                dismiss()
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("삭제한 작품은 복구할 수 없습니다.")
        }
        .onChange(of: navigateToEdit) { _, isEditing in
            if !isEditing {
                reloadImage()
                onChange()
            }
        }
    }

    private func reloadImage() {
        image = LocalStorageService.loadImage(fileName: drawing.fileName)
    }
}
