import Foundation

/// MVP: 전국 센터 목록 (추후 서버·공공데이터 API 연동 예정)
enum CounselingCenterProvider {
    static let dataNotice = "기관 정보는 변경될 수 있습니다. 방문·전화 전 공식 안내를 확인해 주세요."

    static let allCenters: [CounselingCenter] = [
        CounselingCenter(
            id: "mhrc_national",
            name: "국가정신건강센터 (정신건강위기상담)",
            category: .suicidePrevention,
            address: "전국 대표 (온라인·전화 상담)",
            phone: "1577-0199",
            hours: "24시간",
            summary: "정신건강 위기 상담·자살예방 안내를 제공합니다.",
            latitude: 37.5665,
            longitude: 126.9780,
            region: "전국"
        ),
        CounselingCenter(
            id: "seoul_suicide",
            name: "서울시 자살예방센터",
            category: .suicidePrevention,
            address: "서울특별시 중구 을지로 100 (을지로 지역)",
            phone: "02-880-1579",
            hours: "평일 09:00–18:00 (기관 안내 기준)",
            summary: "서울시민 대상 자살예방·위기 상담 연계.",
            latitude: 37.5660,
            longitude: 126.9910,
            region: "서울"
        ),
        CounselingCenter(
            id: "busan_suicide",
            name: "부산 자살예방센터",
            category: .suicidePrevention,
            address: "부산광역시 연제구 중앙대로 1001",
            phone: "051-990-3399",
            hours: "평일 09:00–18:00 (기관 안내 기준)",
            summary: "부산 지역 위기 개입·상담 연계.",
            latitude: 35.1880,
            longitude: 129.0820,
            region: "부산"
        ),
        CounselingCenter(
            id: "daegu_mh",
            name: "대구권역 정신건강복지센터",
            category: .mentalHealthWelfare,
            address: "대구광역시 중구 달구벌대로 2058",
            phone: "053-430-8800",
            hours: "평일 09:00–18:00",
            summary: "정신건강 검진·상담·회복 지원.",
            latitude: 35.8710,
            longitude: 128.6010,
            region: "대구"
        ),
        CounselingCenter(
            id: "gwangju_counsel",
            name: "광주광역시 정신건강복지센터",
            category: .mentalHealthWelfare,
            address: "광주광역시 서구 상무자유로 749",
            phone: "062-600-8800",
            hours: "평일 09:00–18:00",
            summary: "광주 지역 정신건강 상담·치료 연계.",
            latitude: 35.1520,
            longitude: 126.8890,
            region: "광주"
        ),
        CounselingCenter(
            id: "daejeon_counsel",
            name: "대전광역시 정신건강복지센터",
            category: .mentalHealthWelfare,
            address: "대전광역시 서구 둔산로 100",
            phone: "042-600-8800",
            hours: "평일 09:00–18:00",
            summary: "대전 지역 심리·정신건강 복지 서비스.",
            latitude: 36.3500,
            longitude: 127.3850,
            region: "대전"
        ),
        CounselingCenter(
            id: "incheon_psych",
            name: "인천광역시 정신건강복지센터",
            category: .mentalHealthWelfare,
            address: "인천광역시 남동구 인주대로 593",
            phone: "032-440-8800",
            hours: "평일 09:00–18:00",
            summary: "인천 지역 정신건강 상담·사례관리.",
            latitude: 37.4480,
            longitude: 126.7310,
            region: "인천"
        ),
        CounselingCenter(
            id: "seoul_mind",
            name: "서울시 마음건강센터",
            category: .psychologicalCounseling,
            address: "서울특별시 종로구 청계천로 159",
            phone: "02-109",
            hours: "365일 (ARS 안내)",
            summary: "서울시민 대상 심리·정서 상담 안내.",
            latitude: 37.5690,
            longitude: 126.9788,
            region: "서울"
        ),
        CounselingCenter(
            id: "kcpa_info",
            name: "한국심리학회 상담심리 안내",
            category: .psychologicalCounseling,
            address: "서울특별시 서초구 (온라인·전화 안내)",
            phone: "02-3444-2800",
            hours: "평일 09:00–17:00",
            summary: "공인 상담심리사 검색·상담 기관 안내.",
            latitude: 37.4830,
            longitude: 127.0320,
            region: "서울"
        ),
        CounselingCenter(
            id: "jeju_mh",
            name: "제주권역 정신건강복지센터",
            category: .mentalHealthWelfare,
            address: "제주특별자치도 제주시 연삼로 219",
            phone: "064-710-8800",
            hours: "평일 09:00–18:00",
            summary: "제주 지역 정신건강 복지·상담.",
            latitude: 33.4990,
            longitude: 126.5310,
            region: "제주"
        )
    ]

    static func centers(filter: CenterCategory) -> [CounselingCenter] {
        guard filter != .all else { return allCenters }
        return allCenters.filter { $0.category == filter }
    }
}
