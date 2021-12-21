import SpriteKit

final class PlayerNode: SKShapeNode {
    private var feetNode = SKShapeNode()
    private let width: CGFloat = 30
    private let height: CGFloat = 40
    private let cornerRadius: CGFloat = 8
    private let walkForceMultiplier: Float = 50
    private let jumpImpulseMultiplier = 30
    private let groundDetectionRange: CGFloat = 30
    private let topWalkSpeed: CGFloat = 300

    override init() {
        super.init()
        path = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: cornerRadius).path
        fillColor = .red
        physicsBody = SKPhysicsBody(rectangleOf: frame.size)
        physicsBody?.restitution = 0
        physicsBody?.friction = 0.5
        physicsBody?.linearDamping = 0.9
        physicsBody?.allowsRotation = false

        feetNode = SKShapeNode(rectOf: CGSize(width: width, height: groundDetectionRange))
        feetNode.position = CGPoint(x: 0, y: -frame.height / 2)
        feetNode.fillColor = .blue.withAlphaComponent(0.3)

        addChild(feetNode)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func walk(dx: Float) {
        guard let physicsBody = physicsBody else { return }
        if physicsBody.velocity.dx >= abs(topWalkSpeed) { return }
        physicsBody.applyForce(CGVector(dx: Int(dx * walkForceMultiplier) , dy: 0))
    }

    func jump() {
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpImpulseMultiplier))
    }

    func shoot(at point: CGPoint) {
        print("Shooting!")
    }

    func isOnTop(of node: SKNode) -> Bool {
        return feetNode.intersects(node)
    }
}


