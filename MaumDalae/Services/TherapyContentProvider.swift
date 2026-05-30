import Foundation

enum TherapyContentProvider {
    static let templates: [TherapyTemplate] = [
        TherapyTemplate(
            id: "rainbow_bridge",
            title: "무지개다리 추억",
            prompt: "함께했던 가장 따뜻한 하루를 떠올리며, 하늘과 발자국을 그려 보세요.",
            persona: .petLoss
        ),
        TherapyTemplate(
            id: "memory_paw",
            title: "발자국 색채",
            prompt: "반려 친구의 발자국 자리에 감사한 마음의 색을 채워 보세요.",
            persona: .petLoss
        ),
        TherapyTemplate(
            id: "hometown",
            title: "고향 풍경",
            prompt: "어릴 적 고향의 집, 나무, 하늘을 기억하며 천천히 색을 입혀 보세요.",
            persona: .senior
        ),
        TherapyTemplate(
            id: "young_days",
            title: "젊은 날의 나",
            prompt: "가장 즐거웠던 날의 옷차림과 미소를 상상하며 그려 보세요.",
            persona: .senior
        ),
        TherapyTemplate(
            id: "free_sketch",
            title: "자유 스케치",
            prompt: "오늘 마음에 드는 색으로 자유롭게 표현해 보세요.",
            persona: nil
        )
    ]

    static func templates(for persona: UserPersona) -> [TherapyTemplate] {
        templates.filter { $0.persona == nil || $0.persona == persona }
    }

    static func template(forTitle title: String, persona: UserPersona) -> TherapyTemplate {
        templates(for: persona).first { $0.title == title }
            ?? templates.first { $0.id == "free_sketch" }!
    }

    static let htpDisclaimer = """
    본 HTP(집-나무-사람) 분석은 AI와 심리학적 이론을 바탕으로 한 참고용 가이드이며, \
    전문 정신과 의사나 임상심리사의 진단·치료를 대체할 수 없습니다. \
    결과는 개인의 상태를 단정하지 않으며, 필요 시 반드시 전문가 상담을 받으시기 바랍니다.
    """

    static let crisisHotline = "1393"
    static let crisisHotlineLabel = "자살예방 상담전화 1393"
}
