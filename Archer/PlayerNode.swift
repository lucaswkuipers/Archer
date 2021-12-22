import SpriteKit

final class PlayerNode: SKShapeNode {
    private var feetNode = SKShapeNode()
    private var armJointNode = SKShapeNode()
    private var armNode = SKShapeNode()
    private let width: CGFloat = 30
    private let height: CGFloat = 40
    private let cornerRadius: CGFloat = 8
    private let walkForceMultiplier: Float = 50
    private let jumpImpulseMultiplier = 30
    private let groundDetectionRange: CGFloat = 30
    private let topWalkSpeed: CGFloat = 300
    private let rotationSpeed = CGFloat((2 * Double.pi) / 2)
    private let lastUpdateTime: CFTimeInterval = 0

    override init() {
        super.init()
        path = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: cornerRadius).path
        fillColor = .red
        strokeColor = .black
        physicsBody = SKPhysicsBody(rectangleOf: frame.size)
        physicsBody?.restitution = 0
        physicsBody?.friction = 0.5
        physicsBody?.linearDamping = 0.9
        physicsBody?.allowsRotation = false

        feetNode = SKShapeNode(rectOf: CGSize(width: width, height: groundDetectionRange))
        feetNode.position = CGPoint(x: 0, y: -frame.height / 2)
        feetNode.fillColor = .blue.withAlphaComponent(0.1)
        feetNode.strokeColor = .clear

        armJointNode = SKShapeNode(rectOf: CGSize(width: 10, height: 10))
        armJointNode.fillColor = .clear
        armJointNode.strokeColor = .clear

        armNode = SKShapeNode(rectOf: CGSize(width: 10, height: 30), cornerRadius: 10)
        armNode.position = CGPoint(x: 0, y: -armNode.frame.height / 3)
        armNode.fillColor = .red
        armNode.strokeColor = .black


        addChild(feetNode)
        addChild(armJointNode)
        armJointNode.addChild(armNode)
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

    func aim(at point: CGPoint) {
        let angle = atan2(point.y , point.x)
        rotate(to: angle + 90)
    }

    func shoot(at point: CGPoint) {
        print("Shooting!")
    }

    func isOnTop(of node: SKNode) -> Bool {
        return feetNode.intersects(node)
    }

    func rotate(to angle: CGFloat) {
        let angleToRotateBy = abs(angle - armJointNode.zRotation)
        let rotationTime = TimeInterval(angleToRotateBy / 60.0)
        let rotateAction = SKAction.rotate(toAngle: angle, duration: rotationTime , shortestUnitArc: true)
        armJointNode.run(rotateAction)
    }
}


