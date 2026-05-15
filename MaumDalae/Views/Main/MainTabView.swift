import SwiftUI

struct MainTabView: View {
    let persona: UserPersona
    @State private var selectedTab = 0

    private var palette: PersonaPalette { AppTheme.palette(for: persona) }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(persona: persona)
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }
                .tag(0)

            GalleryView(persona: persona)
                .tabItem {
                    Label("갤러리", systemImage: "photo.stack.fill")
                }
                .tag(1)

            SettingsView(persona: persona)
                .tabItem {
                    Label("설정", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(palette.primary)
    }
}
