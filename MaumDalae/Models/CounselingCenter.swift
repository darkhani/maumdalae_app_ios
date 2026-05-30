import CoreLocation
import Foundation

enum CenterCategory: String, CaseIterable, Identifiable, Codable {
    case all
    case suicidePrevention
    case psychologicalCounseling
    case mentalHealthWelfare

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return "전체"
        case .suicidePrevention: return "자살예방"
        case .psychologicalCounseling: return "심리상담"
        case .mentalHealthWelfare: return "정신건강복지"
        }
    }

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .suicidePrevention: return "heart.text.square"
        case .psychologicalCounseling: return "person.2.wave.2"
        case .mentalHealthWelfare: return "cross.case"
        }
    }
}

struct CounselingCenter: Identifiable, Hashable {
    let id: String
    let name: String
    let category: CenterCategory
    let address: String
    let phone: String
    let hours: String
    let summary: String
    let latitude: Double
    let longitude: Double
    let region: String

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var phoneURL: URL? {
        let digits = phone.filter { $0.isNumber || $0 == "+" }
        guard !digits.isEmpty else { return nil }
        return URL(string: "tel://\(digits)")
    }

    var mapURL: URL? {
        let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
        return URL(string: "http://maps.apple.com/?q=\(encoded)&ll=\(latitude),\(longitude)")
    }
}
