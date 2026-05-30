import Foundation

struct HTPAnalysis: Identifiable, Codable, Hashable {
    let id: UUID
    let imageFileName: String
    let detectedObjects: [String: String]
    let structuralFeatures: StructuralFeatures
    let healingMessage: String
    let recommendation: String
    let createdAt: Date
    var showsCrisisAlert: Bool
}

struct StructuralFeatures: Codable, Hashable {
    let position: String
    let pressure: String
    let lineQuality: String
}

struct SavedDrawing: Identifiable, Codable, Hashable {
    let id: UUID
    let persona: UserPersona
    let title: String
    let fileName: String
    let createdAt: Date
}

struct TherapyTemplate: Identifiable {
    let id: String
    let title: String
    let prompt: String
    let persona: UserPersona?
}
