import Foundation
import UIKit

/// MVP: 서버·AI 연동 전 로컬 휴리스틱 + 샘플 리포트 (추후 FastAPI/YOLO 파이프라인으로 교체)
enum HTPAnalysisService {
    static func analyze(image: UIImage, persona: UserPersona) async -> HTPAnalysis {
        try? await Task.sleep(nanoseconds: 1_800_000_000)

        let brightness = averageBrightness(image)
        let isDark = brightness < 0.22
        let showsCrisis = isDark

        let healingMessage: String
        let recommendation: String
        let structural: StructuralFeatures

        if showsCrisis {
            healingMessage = "지금 마음이 많이 무겁게 느껴지실 수 있어요. 혼자 견디지 않으셔도 됩니다."
            recommendation = persona == .senior
                ? "가까운 정신건강복지센터 상담과 함께, 따뜻한 색의 회상 컬러링 세션을 천천히 시작해 보세요."
                : "전문 상담 연결 후, 무지개다리 추억 캔버스로 한 걸음씩 마음을 표현해 보세요."
            structural = StructuralFeatures(
                position: "중앙 치우침",
                pressure: "약함",
                lineQuality: "끊김·어두움"
            )
        } else if brightness < 0.45 {
            healingMessage = "현재 마음에 비가 내리고 있군요. 과거의 따뜻한 기억을 그리워하고 계시네요."
            recommendation = persona == .senior
                ? "고향 풍경 컬러링 세션으로 안정감을 쌓아 보세요."
                : "반려 친구와 함께했던 행복한 순간을 파스텔 색으로 그려 보세요."
            structural = StructuralFeatures(
                position: "하단·좌측",
                pressure: "보통",
                lineQuality: "다소 흐림"
            )
        } else {
            healingMessage = "표현하신 그림에서 회복의 기운이 느껴집니다. 스스로를 돌보고 계시네요."
            recommendation = persona == .senior
                ? "젊은 날의 즐거웠던 기억을 주제로 한 활력 세션을 추천드려요."
                : "무지개다리 스토리텔링 템플릿으로 추억을 통합해 보세요."
            structural = StructuralFeatures(
                position: "균형",
                pressure: "안정",
                lineQuality: "연속적"
            )
        }

        let fileName: String
        do {
            fileName = try LocalStorageService.saveHTPImage(image)
        } catch {
            fileName = "htp_unsaved.jpg"
        }

        return HTPAnalysis(
            id: UUID(),
            imageFileName: fileName,
            detectedObjects: [
                "house": "감지됨 · 문·창 표현 확인",
                "tree": "감지됨 · 줄기·가지 구조",
                "person": "감지됨 · 전신 실루엣"
            ],
            structuralFeatures: structural,
            healingMessage: healingMessage,
            recommendation: recommendation,
            createdAt: Date(),
            showsCrisisAlert: showsCrisis
        )
    }

    private static func averageBrightness(_ image: UIImage) -> CGFloat {
        guard let cg = image.cgImage else { return 0.5 }
        let width = min(cg.width, 80)
        let height = min(cg.height, 80)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        guard let ctx = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return 0.5 }

        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))
        var total: CGFloat = 0
        let count = width * height
        for i in stride(from: 0, to: pixels.count, by: 4) {
            let r = CGFloat(pixels[i]) / 255
            let g = CGFloat(pixels[i + 1]) / 255
            let b = CGFloat(pixels[i + 2]) / 255
            total += (r + g + b) / 3
        }
        return total / CGFloat(count)
    }
}
