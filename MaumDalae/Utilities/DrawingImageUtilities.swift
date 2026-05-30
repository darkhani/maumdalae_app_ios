import UIKit

enum DrawingImageUtilities {
    /// JPEG 저장 시 투명 픽셀이 검정으로 바뀌는 것을 막기 위해 불투명 흰 배경으로 합성합니다.
    static func flattenedOnWhiteBackground(_ image: UIImage, scale: CGFloat? = nil) -> UIImage {
        let pixelSize = CGSize(
            width: image.size.width * image.scale,
            height: image.size.height * image.scale
        )
        guard pixelSize.width > 0, pixelSize.height > 0 else { return image }

        let renderScale = scale ?? image.scale
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        format.scale = renderScale

        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: image.size))
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }

    static func compositeOnWhite(
        background: UIImage?,
        strokes: UIImage,
        size: CGSize,
        scale: CGFloat
    ) -> UIImage {
        guard size.width > 0, size.height > 0 else { return strokes }

        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        format.scale = scale

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            if let background {
                let normalized = flattenedOnWhiteBackground(background, scale: scale)
                normalized.draw(in: CGRect(origin: .zero, size: size))
            }

            // 스트로크는 투명 영역을 유지한 채 합성 (흰색으로 먼저 평탄화하면 배경 그림을 덮음)
            strokes.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
