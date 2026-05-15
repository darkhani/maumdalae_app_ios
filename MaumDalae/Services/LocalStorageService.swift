import Foundation
import UIKit

enum LocalStorageService {
    private static var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static func saveDrawing(_ image: UIImage, id: UUID = UUID()) throws -> String {
        let fileName = "drawing_\(id.uuidString).jpg"
        let url = documentsURL.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            throw StorageError.encodingFailed
        }
        try data.write(to: url, options: .atomic)
        return fileName
    }

    static func saveHTPImage(_ image: UIImage, id: UUID = UUID()) throws -> String {
        let fileName = "htp_\(id.uuidString).jpg"
        let url = documentsURL.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 0.78) else {
            throw StorageError.encodingFailed
        }
        try data.write(to: url, options: .atomic)
        return fileName
    }

    static func loadImage(fileName: String) -> UIImage? {
        let url = documentsURL.appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    static func listDrawings() -> [SavedDrawing] {
        guard let data = UserDefaults.standard.data(forKey: "maumdalae.drawings"),
              let items = try? JSONDecoder().decode([SavedDrawing].self, from: data) else {
            return []
        }
        return items.sorted { $0.createdAt > $1.createdAt }
    }

    static func appendDrawing(_ drawing: SavedDrawing) {
        var items = listDrawings()
        items.insert(drawing, at: 0)
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: "maumdalae.drawings")
        }
    }

    static func listHTPAnalyses() -> [HTPAnalysis] {
        guard let data = UserDefaults.standard.data(forKey: "maumdalae.htp"),
              let items = try? JSONDecoder().decode([HTPAnalysis].self, from: data) else {
            return []
        }
        return items.sorted { $0.createdAt > $1.createdAt }
    }

    static func appendHTP(_ analysis: HTPAnalysis) {
        var items = listHTPAnalyses()
        items.insert(analysis, at: 0)
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: "maumdalae.htp")
        }
    }

    enum StorageError: Error {
        case encodingFailed
    }
}
