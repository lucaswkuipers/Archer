import SpriteKit

final class PlayerNode: SKShapeNode {
    private var feetNode = SKShapeNode()
    private var armJointNode = SKShapeNode()
    private var armNode = SKShapeNode()

    private let width: CGFloat = 30
    private let height: CGFloat = 40
    private let cornerRadius: CGFloat = 8

    private let projectileRadius: CGFloat = 10
    private let projectileMass: CGFloat = 0.01

    private let walkForceMultiplier: Float = 50
    private let jumpImpulseMultiplier = 30
    private let groundDetectionRange: CGFloat = 5
    private let topWalkSpeed: CGFloat = 300
    private let rotationSpeed = CGFloat((2 * Double.pi) / 2)
    private let lastUpdateTime: CFTimeInterval = 0
    private let throwStrength: CGFloat = 10

    override init() {
        super.init()

        setupNode()
        setupSubNodes()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Public

    func walk(dx: Float) {
        guard let physicsBody = physicsBody else { return }
        if physicsBody.velocity.dx >= abs(topWalkSpeed) { return }
        physicsBody.applyForce(CGVector(dx: Int(dx * walkForceMultiplier) , dy: 0))
    }

    func jump() {
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: jumpImpulseMultiplier))
    }

    func aim(at angle: Double) {
        let angleToRotateBy = abs(angle - armJointNode.zRotation)
        let rotationSpeed = 50.0
        let rotationTime = TimeInterval(angleToRotateBy / rotationSpeed)
        let rotateAction = SKAction.rotate(toAngle: angle, duration: rotationTime , shortestUnitArc: true)
        armJointNode.run(rotateAction)
    }

    func shoot() {
        let projectile = makeProjectile()
        let angle = getAimingAngle()
        let dx = throwStrength * cos(angle)
        let dy = throwStrength * sin(angle)

        scene?.addChild(projectile)
        projectile.position = getHandPosition()
        projectile.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))

        print("Shoot! Angle: \(angle), dx: \(dx), dy: \(dy)")
    }

    func isOnFloor() -> Bool {
        guard let scene = scene else { return false }

        for child in scene.children {
            if feetNode.intersects(child) { return true }
        }
        return false
    }

    // MARK: - Private

    private func setupNode() {
        setupNodeStyle()
        setupNodePhysics()
    }

    private func setupNodeStyle() {
        path = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: cornerRadius).path
        fillColor = .red
        strokeColor = .black
    }

    private func setupNodePhysics() {
        physicsBody = SKPhysicsBody(rectangleOf: frame.size)
        physicsBody?.restitution = 0
        physicsBody?.friction = 0.5
        physicsBody?.linearDamping = 0.9
        physicsBody?.allowsRotation = false
    }

    private func setupSubNodes() {
        feetNode = SKShapeNode(rectOf: CGSize(width: width - 2, height: groundDetectionRange))
        feetNode.position = CGPoint(x: 0, y: -(frame.height + feetNode.frame.height) / 2)
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

    private func makeProjectile() -> SKShapeNode {
        let projectile = SKShapeNode(circleOfRadius: 5)
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.frame.width / 2)
        projectile.physicsBody?.mass = projectileMass
        projectile.fillColor = .gray
        let rotation = armJointNode.zRotation + 180
        projectile.position = CGPoint(x: (position.x + armNode.frame.width * cos(rotation)) * 1.1, y: (position.y + armNode.frame.height * sin(rotation) * 1.1))
        return projectile
    }

    private func getAimingAngle() -> Double {
        return armJointNode.zRotation - Double.pi / 2
    }

    private func getHandPosition() -> CGPoint {
        let angle = getAimingAngle()
        let radius = armNode.frame.height
        return CGPoint(x: position.x + radius * cos(angle), y: position.y + radius * sin(angle))
    }
}
