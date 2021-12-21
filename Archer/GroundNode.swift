import SpriteKit

final class GroundNode: SKShapeNode {
    private let width: CGFloat = 30
    private let height: CGFloat = 40
    private let cornerRadius: CGFloat = 8
    private let walkForceMultiplier: Float = 50
    private let jumpImpulseMultiplier = 30
    private let groundDetectionRange: CGFloat = 30
    private let topWalkSpeed: CGFloat = 300

    init(width: CGFloat = 0, height: CGFloat = 0) {
        super.init()
        path = SKShapeNode(rectOf: CGSize(width: width, height: height)).path
        fillColor = .white
        physicsBody = SKPhysicsBody(rectangleOf: frame.size)
        physicsBody?.isDynamic = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
