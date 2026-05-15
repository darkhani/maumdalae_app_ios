import SwiftUI

struct GalleryView: View {
    let persona: UserPersona
    @State private var drawings: [SavedDrawing] = []
    @State private var htpItems: [HTPAnalysis] = []
    @State private var segment = 0

    private var palette: PersonaPalette { AppTheme.palette(for: persona) }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("종류", selection: $segment) {
                    Text("그림").tag(0)
                    Text("HTP").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                if segment == 0 {
                    drawingGrid
                } else {
                    htpList
                }
            }
            .background(palette.background)
            .navigationTitle("나만의 갤러리")
            .onAppear { reload() }
        }
    }

    private var drawingGrid: some View {
        Group {
            if drawings.isEmpty {
                emptyState(message: "저장된 그림이 없어요.\n캔버스에서 첫 작품을 남겨 보세요.")
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(drawings.filter { $0.persona == persona }) { item in
                            if let image = LocalStorageService.loadImage(fileName: item.fileName) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 140)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    Text(item.title)
                                        .font(palette.usesHighContrast ? .body.weight(.semibold) : .caption)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }

    private var htpList: some View {
        Group {
            if htpItems.isEmpty {
                emptyState(message: "HTP 검사 기록이 없어요.")
            } else {
                List(htpItems) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        if let image = LocalStorageService.loadImage(fileName: item.imageFileName) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        Text(item.healingMessage)
                            .font(palette.usesHighContrast ? .body : .subheadline)
                        Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(palette.muted)
                    }
                    .listRowBackground(palette.card)
                }
                .scrollContentBackground(.hidden)
            }
        }
    }

    private func emptyState(message: String) -> some View {
        ContentUnavailableView {
            Label("비어 있음", systemImage: "photo.on.rectangle.angled")
        } description: {
            Text(message)
                .font(palette.bodyFont)
                .multilineTextAlignment(.center)
        }
    }

    private func reload() {
        drawings = LocalStorageService.listDrawings()
        htpItems = LocalStorageService.listHTPAnalyses()
    }
}
