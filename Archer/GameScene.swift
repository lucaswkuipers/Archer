import SpriteKit
import GameController

final class GameScene: SKScene {
    private let playerSpeedFactor: Float = 100
    private let playerMaxSpeed: Float = 200
    var controller: GCController?
    let controllerManager = ControllerManager()

    let ground: SKNode = {
        let node = SKShapeNode(rectOf: CGSize(width: 1000, height: 100))
        node.name = "ground"
        node.fillColor = .white
        node.physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.friction = 1.0
        return node
    }()

    let leftWall: SKNode = {
        let node = SKShapeNode(rectOf: CGSize(width: 100, height: 1000))
        node.name = "leftWall"
        node.physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
        node.physicsBody?.isDynamic = false
        node.fillColor = .white
        return node
    }()

    let rightWall: SKNode = {
        let node = SKShapeNode(rectOf: CGSize(width: 100, height: 1000))
        node.name = "rightWall"
        node.physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
        node.physicsBody?.isDynamic = false
        node.fillColor = .white
        return node
    }()

    let ceiling: SKNode = {
        let node = SKShapeNode(rectOf: CGSize(width: 1000, height: 100))
        node.name = "ceiling"
        node.physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
        node.physicsBody?.isDynamic = false
        node.fillColor = .white
        return node
    }()

    let player: SKNode = {
        let node = SKShapeNode(rectOf: CGSize(width: 20, height: 30), cornerRadius: 4)
        node.name = "player"
        node.fillColor = .red
        node.physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
        node.physicsBody?.linearDamping = 0.999
        node.physicsBody?.angularDamping = 0.5
        let rotationDegrees = CGFloat.pi / 2
        let rotationRange = SKRange(lowerLimit: -rotationDegrees, upperLimit: rotationDegrees)
        let rotationConstraint = SKConstraint.zRotation(rotationRange)
        node.constraints = [rotationConstraint]
        return node
    }()

    override func didMove(to view: SKView) {
        addChild(ground)
        addChild(leftWall)
        addChild(rightWall)
        addChild(ceiling)
        addChild(player)
        ground.position = CGPoint(x: 0, y: frame.minY)
        leftWall.position = CGPoint(x: frame.minX, y: frame.midY)
        rightWall.position = CGPoint(x: frame.maxX, y: frame.midY)
        ceiling.position = CGPoint(x: 0, y: frame.maxY)
        player.position = CGPoint(x: 0, y: frame.midY)
        controllerManager.delegate = self
    }

    override func update(_ currentTime: TimeInterval) {
        guard let gamepad = controller?.extendedGamepad else { return }
        let horizontalMovementInput = gamepad.leftThumbstick.xAxis.value
        let horizontalAimInput = gamepad.rightThumbstick.xAxis.value
        let verticalAimInput = gamepad.rightThumbstick.yAxis.value
        move(dx: horizontalMovementInput)
        clampSpeed()
    }

    private func move(dx: Float) {
        let dx = CGFloat(dx * playerSpeedFactor)
//        player.physicsBody?.applyImpulse(CGVector(dx: dx, dy: 0))
        player.physicsBody?.applyForce(CGVector(dx: dx, dy: 0))
    }

    private func clampSpeed() {
        guard var physicsBody = player.physicsBody else { return }
        if physicsBody.velocity.dx > 0 {
            physicsBody.velocity.dx = min(physicsBody.velocity.dx, CGFloat(playerMaxSpeed))
        } else {
            physicsBody.velocity.dx = max(physicsBody.velocity.dx, -CGFloat(playerMaxSpeed))
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        player.position = location
        player.physicsBody?.isDynamic = false
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        player.position = location
        player.physicsBody?.isDynamic = false
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        player.position = location
        player.physicsBody?.isDynamic = true
    }
}

extension GameScene: ControllerManagerDelegate {
    func didConnect(_ controller: GCController) {
        print("Controller connected!")
        print("Controller \(controller.debugDescription)")
        self.controller = controller
    }

    func didDisconnectController() {
        print("Controller disconnected")
    }

    func didReceiveControllerInput(gamepad: GCExtendedGamepad, element: GCControllerElement, index: Int) {
        print("Did receive controller input: \(element.debugDescription)")
    }
}
