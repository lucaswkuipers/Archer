import SpriteKit
import GameController

final class GameScene: SKScene {
    private let controllerManager = ControllerManager()

    // MARK: - Scene Configuration

    private let maxVelocity: CGFloat = 1_000
    private let groundHoleWidth: CGFloat = 150
    private let groundHeight: CGFloat = 100
    private let wallHoleHeight: CGFloat = 150
    private let wallWidth: CGFloat = 100

    // MARK: - Scene Nodes

    private var groundLeftNode = GroundNode()
    private var groundRightNode = GroundNode()
    private var ceilingLeftNode = SKShapeNode()
    private var ceilingRightNode = SKShapeNode()
    private var leftWallTopNode = SKShapeNode()
    private var leftWallBottomNode = SKShapeNode()
    private var rightWallTopNode = SKShapeNode()
    private var rightWallBottomNode = SKShapeNode()
    private var playerNode = PlayerNode()

    // MARK: - Scene State

    private var controller = GCController()
    private var canShoot = true

    // MARK: - Scene Events

    override func didMove(to view: SKView) {
        addGround()
        addCeiling()
        addWalls()
        addPlayer()
        setDelegates()
        physicsBody?.contactTestBitMask = 0
    }

    override func update(_ currentTime: TimeInterval) {
        teleportObjectsToSceneBounds()
        handlePlayerMovement()
        limitObjectsVelocity()
    }

    // MARK: - Scene Objects Setup

    private func addGround() {
        let groundLeftNode = GroundNode(width: (frame.width - groundHoleWidth) / 2, height: groundHeight)
        groundLeftNode.position = CGPoint(x: frame.minX + groundLeftNode.frame.width / 2, y: frame.minY)

        let groundRightNode = GroundNode(width: (frame.width - groundHoleWidth) / 2, height: groundHeight)
        groundRightNode.position = CGPoint(x: frame.maxX - groundRightNode.frame.width / 2, y: frame.minY)

        addChild(groundLeftNode)
        addChild(groundRightNode)

        self.groundLeftNode = groundLeftNode
        self.groundRightNode = groundRightNode
    }

    private func addCeiling() {
        let ceilingLeftNode = SKShapeNode(rectOf: CGSize(width: (frame.width - groundHoleWidth) / 2, height: groundHeight))
        ceilingLeftNode.position = CGPoint(x: frame.minX + ceilingLeftNode.frame.width / 2, y: frame.maxY)
        ceilingLeftNode.fillColor = .white
        ceilingLeftNode.physicsBody = SKPhysicsBody(rectangleOf: ceilingLeftNode.frame.size)
        ceilingLeftNode.physicsBody?.isDynamic = false

        let ceilingRightNode = SKShapeNode(rectOf: CGSize(width: (frame.width - groundHoleWidth) / 2, height: groundHeight))
        ceilingRightNode.position = CGPoint(x: frame.maxX - ceilingRightNode.frame.width / 2, y: frame.maxY)
        ceilingRightNode.fillColor = .white
        ceilingRightNode.physicsBody = SKPhysicsBody(rectangleOf: ceilingRightNode.frame.size)
        ceilingRightNode.physicsBody?.isDynamic = false

        addChild(ceilingLeftNode)
        addChild(ceilingRightNode)

        self.ceilingLeftNode = ceilingLeftNode
        self.ceilingRightNode = ceilingRightNode
    }

    private func addWalls() {
        let leftWallTopNode = SKShapeNode(rectOf: CGSize(width: wallWidth, height: (frame.height - wallHoleHeight) / 2))
        leftWallTopNode.position = CGPoint(x: frame.minX, y: frame.maxY - leftWallTopNode.frame.height / 2)
        leftWallTopNode.fillColor = .white
        leftWallTopNode.physicsBody = SKPhysicsBody(rectangleOf: leftWallTopNode.frame.size)
        leftWallTopNode.physicsBody?.isDynamic = false
        leftWallTopNode.physicsBody?.restitution = 0

        let leftWallBottomNode = SKShapeNode(rectOf: CGSize(width: wallWidth, height: (frame.height - wallHoleHeight) / 2))
        leftWallBottomNode.position = CGPoint(x: frame.minX, y: frame.minY + leftWallBottomNode.frame.height / 2)
        leftWallBottomNode.fillColor = .white
        leftWallBottomNode.physicsBody = SKPhysicsBody(rectangleOf: leftWallBottomNode.frame.size)
        leftWallBottomNode.physicsBody?.isDynamic = false
        leftWallBottomNode.physicsBody?.restitution = 0

        let rightWallTopNode = SKShapeNode(rectOf: CGSize(width: wallWidth, height: (frame.height - wallHoleHeight) / 2))
        rightWallTopNode.position = CGPoint(x: frame.maxX, y: frame.maxY - rightWallTopNode.frame.height / 2)
        rightWallTopNode.fillColor = .white
        rightWallTopNode.physicsBody = SKPhysicsBody(rectangleOf: rightWallTopNode.frame.size)
        rightWallTopNode.physicsBody?.isDynamic = false
        rightWallTopNode.physicsBody?.restitution = 0

        let rightWallBottomNode = SKShapeNode(rectOf: CGSize(width: wallWidth, height: (frame.height - wallHoleHeight) / 2))
        rightWallBottomNode.position = CGPoint(x: frame.maxX, y: frame.minY + rightWallBottomNode.frame.height / 2)
        rightWallBottomNode.fillColor = .white
        rightWallBottomNode.physicsBody = SKPhysicsBody(rectangleOf: rightWallBottomNode.frame.size)
        rightWallBottomNode.physicsBody?.isDynamic = false
        rightWallBottomNode.physicsBody?.restitution = 0

        addChild(leftWallTopNode)
        addChild(leftWallBottomNode)
        addChild(rightWallTopNode)
        addChild(rightWallBottomNode)

        self.leftWallTopNode = leftWallTopNode
        self.leftWallBottomNode = leftWallBottomNode
        self.rightWallTopNode = rightWallTopNode
        self.rightWallBottomNode = rightWallBottomNode
    }

    private func addPlayer() {
        playerNode.position = CGPoint(x: frame.midX - groundHoleWidth, y: frame.midY)
        addChild(playerNode)
    }

    private func setDelegates() {
        controllerManager.delegate = self
    }

    // MARK: - Player Movement

    private func handlePlayerMovement() {
        guard let dx = controller.extendedGamepad?.leftThumbstick.xAxis.value else { return }
        walk(dx: dx)
    }

    private func teleportObjectsToSceneBounds() {
        guard let scene = scene else { return }

        for child in scene.children {
            // Ignore platforms
            if isPlatform(child) { continue }

            // Right
            if child.position.x >= frame.maxX + child.frame.width / 2 {
                child.position.x = frame.minX - child.frame.width / 2
            }
            // Left
            else if child.position.x <= frame.minX - child.frame.width / 2 {
                child.position.x = frame.maxX + child.frame.width / 2
            }

            // Top
            if child.position.y >= frame.maxY + child.frame.height / 2 {
                child.position.y = frame.minY - child.frame.height / 2
            }

            // Bottom
            else if child.position.y <= frame.minY - child.frame.height / 2 {
                child.position.y = frame.maxY + child.frame.height / 2
            }
        }
    }

    private func limitObjectsVelocity() {
        guard let scene = scene else { return }

        for child in scene.children {
            guard let velocity = child.physicsBody?.velocity else { return }

            child.physicsBody?.velocity.dx = velocity.dx > 0 ? min(velocity.dx, maxVelocity) : max(velocity.dx, -maxVelocity)
            child.physicsBody?.velocity.dy = velocity.dy > 0 ? min(velocity.dy, maxVelocity) : max(velocity.dy, -maxVelocity)
        }
    }

    // MARK: - Player Actions

    private func walk(dx: Float) {
        playerNode.walk(dx: dx)
    }

    private func jump() {
        let isGrounded = playerNode.isOnFloor()
        if isGrounded {
            playerNode.jump()
        }
    }

    private func shoot() {
        playerNode.shoot()
    }

    // MARK: - Player Input Management

    private func addInputHandlers() {
        guard let gamepad = controller.extendedGamepad else { return }

        // Jump
        gamepad.buttonA.pressedChangedHandler = { (_, _, isPressed) in
            if isPressed {
                self.jump()
            }
        }

        // Shoot
        gamepad.rightTrigger.valueChangedHandler = { (_, value, isPressed) in
            if value >= 0.8 && self.canShoot {
                self.shoot()
                self.canShoot = false
            }

            if value <= 0.1 {
                self.canShoot = true
            }
        }

        // Aim
        gamepad.leftThumbstick.valueChangedHandler = {(_, xValue, yValue) in
            print("xValue: \(xValue)")
            print("yValue: \(yValue)")
            let deadZone: Float = 0.2
            if abs(xValue) < deadZone && abs(yValue) < deadZone { return }

            let angle = Double(atan2(yValue, xValue)) + .pi / 2
            print(angle)
            self.playerNode.aim(at: angle)
        }
    }

    private func setAdaptiveTriggersIfDualSense() {
        guard let rightTrigger = controller.extendedGamepad?.rightTrigger as? GCDualSenseAdaptiveTrigger else { return }
        rightTrigger.setModeWeaponWithStartPosition(0, endPosition: 0.6, resistiveStrength: 1)
    }

    // MARK: - Helpers

    private func isPlatform(_ node: SKNode) -> Bool {
        return node.isEqual(to: groundLeftNode) || node.isEqual(to: groundRightNode) || node.isEqual(to: ceilingLeftNode) || node.isEqual(to: ceilingRightNode) || node.isEqual(to: leftWallTopNode) || node.isEqual(to: leftWallBottomNode) || node.isEqual(to: rightWallTopNode) || node.isEqual(to: rightWallBottomNode)
    }
}

extension GameScene: ControllerManagerDelegate {
    func didConnect(_ controller: GCController) {
        self.controller = controller
        addInputHandlers()
        setAdaptiveTriggersIfDualSense()
        print("Did connect controller!")
    }

    func didDisconnectController() {
        print("Did disconnect controller")
    }
}
