import SwiftUI

struct GalleryView: View {
    let persona: UserPersona
    @State private var drawings: [SavedDrawing] = []
    @State private var htpItems: [HTPAnalysis] = []
    @State private var segment = 0
    @State private var selectedDrawing: SavedDrawing?
    @State private var selectedHTP: HTPAnalysis?

    private var palette: PersonaPalette { AppTheme.palette(for: persona) }

    private var filteredDrawings: [SavedDrawing] {
        drawings.filter { $0.persona == persona }
    }

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
            .navigationDestination(item: $selectedDrawing) { drawing in
                GalleryDrawingDetailView(drawing: drawing, persona: persona) {
                    reload()
                }
            }
            .navigationDestination(item: $selectedHTP) { item in
                GalleryHTPDetailView(analysis: item, persona: persona)
            }
        }
    }

    private var drawingGrid: some View {
        Group {
            if filteredDrawings.isEmpty {
                emptyState(message: "저장된 그림이 없어요.\n캔버스에서 첫 작품을 남겨 보세요.")
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(filteredDrawings) { item in
                            Button {
                                selectedDrawing = item
                            } label: {
                                drawingThumbnail(item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
        }
    }

    @ViewBuilder
    private func drawingThumbnail(_ item: SavedDrawing) -> some View {
        if let image = LocalStorageService.loadImage(fileName: item.fileName) {
            VStack(alignment: .leading, spacing: 6) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 140)
                    .background(Color.white)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Text(item.title)
                    .font(palette.usesHighContrast ? .body.weight(.semibold) : .caption)
                    .foregroundStyle(palette.text)
                    .lineLimit(1)
                Text("탭하여 크게 보기")
                    .font(.caption2)
                    .foregroundStyle(palette.muted)
            }
        }
    }

    private var htpList: some View {
        Group {
            if htpItems.isEmpty {
                emptyState(message: "HTP 검사 기록이 없어요.")
            } else {
                List(htpItems) { item in
                    Button {
                        selectedHTP = item
                    } label: {
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
                                .foregroundStyle(palette.text)
                                .multilineTextAlignment(.leading)
                            Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(palette.muted)
                        }
                    }
                    .buttonStyle(.plain)
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

// MARK: - HTP 전체 화면 보기

private struct GalleryHTPDetailView: View {
    let analysis: HTPAnalysis
    let persona: UserPersona

    private var palette: PersonaPalette { AppTheme.palette(for: persona) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let image = LocalStorageService.loadImage(fileName: analysis.imageFileName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
                }
                Text(analysis.healingMessage)
                    .font(palette.bodyFont)
                Text(analysis.recommendation)
                    .font(palette.bodyFont)
                    .foregroundStyle(palette.muted)
                Text(analysis.createdAt.formatted(date: .long, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(palette.muted)
            }
            .padding(20)
        }
        .background(palette.background)
        .navigationTitle("HTP 기록")
        .navigationBarTitleDisplayMode(.inline)
    }
}
