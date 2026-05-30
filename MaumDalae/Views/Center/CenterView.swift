import MapKit
import SwiftUI

struct CenterView: View {
    let persona: UserPersona

    @State private var selectedCategory: CenterCategory = .all
    @State private var selectedCenter: CounselingCenter?
    @State private var mapPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 36.2, longitude: 127.8),
            span: MKCoordinateSpan(latitudeDelta: 5.5, longitudeDelta: 5.5)
        )
    )

    private var palette: PersonaPalette { AppTheme.palette(for: persona) }

    private var filteredCenters: [CounselingCenter] {
        CounselingCenterProvider.centers(filter: selectedCategory)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    crisisBanner
                    categoryFilter
                    mapSection
                    centerListSection
                    dataNoticeFooter
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .background(palette.background)
            .navigationTitle("센터")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if selectedCenter == nil {
                    selectedCenter = filteredCenters.first
                    focusMap(on: filteredCenters.first)
                }
            }
            .onChange(of: selectedCategory) { _, _ in
                let list = filteredCenters
                if let current = selectedCenter, list.contains(current) {
                    focusMap(on: current)
                } else {
                    selectedCenter = list.first
                    focusMap(on: list.first)
                }
            }
        }
    }

    // MARK: - 위기 지원 (설정에서 이전)

    private var crisisBanner: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("지금 마음이 힘드신가요?", systemImage: "heart.circle.fill")
                .font(palette.usesHighContrast ? .title2.weight(.bold) : .headline)
                .foregroundStyle(palette.primary)

            Text("혼자 견디지 않으셔도 됩니다. 아래 번호로 바로 연결할 수 있어요.")
                .font(palette.bodyFont)
                .foregroundStyle(palette.muted)

            if let url = URL(string: "tel://1393") {
                Link(destination: url) {
                    HStack(spacing: 12) {
                        Image(systemName: "phone.fill")
                            .font(palette.usesHighContrast ? .title2 : .title3)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(TherapyContentProvider.crisisHotlineLabel)
                                .font(palette.usesHighContrast ? .title2.weight(.bold) : .headline)
                            Text("24시간 · 무료 · 비밀보장")
                                .font(palette.usesHighContrast ? .body : .caption)
                                .opacity(0.9)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(.white)
                    .padding(18)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.85, green: 0.25, blue: 0.28), Color(red: 0.65, green: 0.18, blue: 0.22)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
                }
            }

            if let url = URL(string: "tel://15770199") {
                Link(destination: url) {
                    HStack {
                        Image(systemName: "phone.circle")
                        Text("정신건강위기상담 1577-0199")
                            .font(palette.usesHighContrast ? .title3 : .subheadline.weight(.medium))
                    }
                    .foregroundStyle(palette.primary)
                    .frame(maxWidth: .infinity, minHeight: palette.buttonMinHeight - 12)
                    .background(palette.card)
                    .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius - 4))
                }
            }
        }
        .padding(18)
        .background(palette.card)
        .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }

    // MARK: - 필터

    private var categoryFilter: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("기관 유형")
                .font(palette.usesHighContrast ? .title3.weight(.bold) : .subheadline.weight(.semibold))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(categoryOptions) { category in
                        let isSelected = selectedCategory == category
                        Button {
                            selectedCategory = category
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: category.icon)
                                Text(category.label)
                            }
                            .font(palette.usesHighContrast ? .body.weight(.semibold) : .subheadline.weight(.medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(isSelected ? palette.primary : palette.primary.opacity(0.1))
                            .foregroundStyle(isSelected ? .white : palette.text)
                            .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }

    private var categoryOptions: [CenterCategory] {
        [.all] + CenterCategory.allCases.filter { $0 != .all }
    }

    // MARK: - 지도

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("지도")
                    .font(palette.usesHighContrast ? .title3.weight(.bold) : .subheadline.weight(.semibold))
                Spacer()
                if let selectedCenter {
                    Text(selectedCenter.region)
                        .font(.caption)
                        .foregroundStyle(palette.muted)
                }
            }

            Map(position: $mapPosition, selection: $selectedCenter) {
                ForEach(filteredCenters) { center in
                    Marker(center.name, coordinate: center.coordinate)
                        .tag(center)
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .frame(height: persona == .senior ? 260 : 220)
            .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: palette.cornerRadius)
                    .stroke(palette.primary.opacity(0.15), lineWidth: 1)
            )
            .onChange(of: selectedCenter) { _, center in
                focusMap(on: center)
            }
        }
    }

    // MARK: - 목록

    private var centerListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("전국 상담·지원 기관")
                .font(palette.usesHighContrast ? .title2.weight(.bold) : .headline)

            if filteredCenters.isEmpty {
                Text("해당 유형의 기관이 없습니다.")
                    .font(palette.bodyFont)
                    .foregroundStyle(palette.muted)
            } else {
                ForEach(filteredCenters) { center in
                    CenterCard(
                        center: center,
                        palette: palette,
                        isSelected: selectedCenter?.id == center.id
                    ) {
                        selectedCenter = center
                        focusMap(on: center)
                    }
                }
            }
        }
    }

    private var dataNoticeFooter: some View {
        Text(CounselingCenterProvider.dataNotice)
            .font(.caption)
            .foregroundStyle(palette.muted)
            .multilineTextAlignment(.leading)
            .padding(.top, 4)
    }

    private func focusMap(on center: CounselingCenter?) {
        guard let center else { return }
        withAnimation(.easeInOut(duration: 0.35)) {
            mapPosition = .region(
                MKCoordinateRegion(
                    center: center.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
                )
            )
        }
    }
}

// MARK: - 기관 카드

private struct CenterCard: View {
    let center: CounselingCenter
    let palette: PersonaPalette
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(center.name)
                            .font(palette.usesHighContrast ? .title3.weight(.bold) : .headline)
                            .foregroundStyle(palette.text)
                            .multilineTextAlignment(.leading)
                        Text(center.category.label)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(palette.accent.opacity(0.15))
                            .foregroundStyle(palette.accent)
                            .clipShape(Capsule())
                    }
                    Spacer()
                    if isSelected {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title2)
                            .foregroundStyle(palette.primary)
                    }
                }

                Text(center.summary)
                    .font(palette.usesHighContrast ? .body : .subheadline)
                    .foregroundStyle(palette.muted)
                    .multilineTextAlignment(.leading)

                Label(center.address, systemImage: "mappin.and.ellipse")
                    .font(palette.usesHighContrast ? .body : .caption)
                    .foregroundStyle(palette.text)
                    .multilineTextAlignment(.leading)

                HStack(spacing: 16) {
                    if let phoneURL = center.phoneURL {
                        Link(destination: phoneURL) {
                            Label(center.phone, systemImage: "phone.fill")
                                .font(palette.usesHighContrast ? .body.weight(.semibold) : .subheadline.weight(.medium))
                        }
                        .foregroundStyle(palette.primary)
                    }

                    if let mapURL = center.mapURL {
                        Link(destination: mapURL) {
                            Label("길찾기", systemImage: "arrow.triangle.turn.up.right.circle")
                                .font(palette.usesHighContrast ? .body : .subheadline)
                        }
                        .foregroundStyle(palette.secondary)
                    }
                }

                Text("운영 \(center.hours)")
                    .font(.caption)
                    .foregroundStyle(palette.muted)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(palette.card)
            .overlay(
                RoundedRectangle(cornerRadius: palette.cornerRadius)
                    .stroke(isSelected ? palette.primary : .clear, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius))
        }
        .buttonStyle(.plain)
    }
}
