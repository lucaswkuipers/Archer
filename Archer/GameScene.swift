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

    private var groundLeftNode = SKShapeNode()
    private var groundRightNode = SKShapeNode()
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
    }

    override func update(_ currentTime: TimeInterval) {
        teleportPlayerToSceneBounds()
        handlePlayerMovement()
        limitPlayerVelocity()
    }

    // MARK: - Scene Objects Setup

    private func addGround() {
        let groundLeftNode = SKShapeNode(rectOf: CGSize(width: (frame.width - groundHoleWidth) / 2, height: groundHeight))
        groundLeftNode.position = CGPoint(x: frame.minX + groundLeftNode.frame.width / 2, y: frame.minY)
        groundLeftNode.fillColor = .white
        groundLeftNode.physicsBody = SKPhysicsBody(rectangleOf: groundLeftNode.frame.size)
        groundLeftNode.physicsBody?.isDynamic = false

        let groundRightNode = SKShapeNode(rectOf: CGSize(width: (frame.width - groundHoleWidth) / 2, height: groundHeight))
        groundRightNode.position = CGPoint(x: frame.maxX - groundRightNode.frame.width / 2, y: frame.minY)
        groundRightNode.fillColor = .white
        groundRightNode.physicsBody = SKPhysicsBody(rectangleOf: groundRightNode.frame.size)
        groundRightNode.physicsBody?.isDynamic = false

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

    private func teleportPlayerToSceneBounds() {
        if playerNode.position.x >= frame.maxX + playerNode.frame.width / 2 {
            playerNode.position.x = frame.minX - playerNode.frame.width / 2
        } else if playerNode.position.x <= frame.minX - playerNode.frame.width / 2 {
            playerNode.position.x = frame.maxX + playerNode.frame.width / 2
        }

        if playerNode.position.y >= frame.maxY + playerNode.frame.height / 2 {
            playerNode.position.y = frame.minY - playerNode.frame.height / 2
        } else if playerNode.position.y <= frame.minY - playerNode.frame.height / 2 {
            playerNode.position.y = frame.maxY + playerNode.frame.height / 2
        }
    }

    private func limitPlayerVelocity() {
        guard let playerVelocity = playerNode.physicsBody?.velocity else { return }
        playerNode.physicsBody?.velocity.dx = playerVelocity.dx > 0 ? min(playerVelocity.dx, maxVelocity) : max(playerVelocity.dx, -maxVelocity)
        playerNode.physicsBody?.velocity.dy = playerVelocity.dy > 0 ? min(playerVelocity.dy, maxVelocity) : max(playerVelocity.dy, -maxVelocity)
    }

    // MARK: - Player Actions

    private func walk(dx: Float) {
        playerNode.walk(dx: dx)
    }

    private func jump() {
        let isGrounded = playerNode.isOnTop(of: groundLeftNode) || playerNode.isOnTop(of: groundRightNode) || playerNode.isOnTop(of: leftWallBottomNode) || playerNode.isOnTop(of: rightWallBottomNode)
        if isGrounded {
            playerNode.jump()
        }
    }

    private func shoot() {
        guard let gamepad = controller.extendedGamepad else { return }

        let horizontalAxisValue = CGFloat(gamepad.rightThumbstick.xAxis.value)
        let verticalAxisValue = CGFloat(gamepad.rightThumbstick.yAxis.value)

        playerNode.shoot(at: CGPoint(x: horizontalAxisValue, y: verticalAxisValue))
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
    }

    private func setAdaptiveTriggersIfDualSense() {
        guard let rightTrigger = controller.extendedGamepad?.rightTrigger as? GCDualSenseAdaptiveTrigger else { return }
        rightTrigger.setModeWeaponWithStartPosition(0, endPosition: 0.6, resistiveStrength: 1)
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
