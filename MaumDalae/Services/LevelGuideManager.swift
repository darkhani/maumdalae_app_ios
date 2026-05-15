import CoreMotion
import Combine

@MainActor
final class LevelGuideManager: ObservableObject {
    @Published var rollDegrees: Double = 0
    @Published var isLevel: Bool = true

    private let motion = CMMotionManager()
    private let levelThreshold: Double = 3.0

    func start() {
        guard motion.isDeviceMotionAvailable else { return }
        motion.deviceMotionUpdateInterval = 0.1
        motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let self, let attitude = data?.attitude else { return }
            let roll = attitude.roll * 180 / .pi
            Task { @MainActor in
                self.rollDegrees = roll
                self.isLevel = abs(roll) < self.levelThreshold
            }
        }
    }

    func stop() {
        motion.stopDeviceMotionUpdates()
    }
}
