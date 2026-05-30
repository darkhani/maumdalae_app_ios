import Foundation
import UIKit

enum LocalStorageService {
    private static var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static func saveDrawing(
        _ image: UIImage,
        id: UUID = UUID(),
        fileName existingFileName: String? = nil
    ) throws -> String {
        let fileName = existingFileName ?? "drawing_\(id.uuidString).jpg"
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
        guard let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else { return nil }
        return DrawingImageUtilities.flattenedOnWhiteBackground(image)
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
        persistDrawings(items)
    }

    static func updateDrawing(_ drawing: SavedDrawing) {
        var items = listDrawings()
        guard let index = items.firstIndex(where: { $0.id == drawing.id }) else { return }
        items[index] = drawing
        persistDrawings(items)
    }

    static func deleteDrawing(id: UUID) {
        var items = listDrawings()
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        let fileName = items[index].fileName
        items.remove(at: index)
        persistDrawings(items)
        let url = documentsURL.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: url)
    }

    private static func persistDrawings(_ items: [SavedDrawing]) {
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
