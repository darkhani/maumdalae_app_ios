import Foundation

enum UserPersona: String, Codable, CaseIterable, Identifiable, Hashable {
    case petLoss
    case senior

    var id: String { rawValue }

    var title: String {
        switch self {
        case .petLoss: return "기억의 숲"
        case .senior: return "인생 사진첩"
        }
    }

    var subtitle: String {
        switch self {
        case .petLoss: return "반려동물과의 추억을 그리며 마음을 돌봅니다"
        case .senior: return "과거의 따뜻한 기억을 색으로 되살립니다"
        }
    }

    var sessionTitle: String {
        switch self {
        case .petLoss: return "펫로스 치유 세션"
        case .senior: return "시니어 활력 세션"
        }
    }
}
