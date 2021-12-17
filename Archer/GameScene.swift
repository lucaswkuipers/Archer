import SpriteKit
import GameController

final class GameScene: SKScene {
    private let controllerManager = ControllerManager()
    private let maxVelocity: CGFloat = 1_000
    private let maxWalkSpeed: CGFloat = 300
    private let groundHoleWidth: CGFloat = 150
    private let groundHeight: CGFloat = 100
    private let wallHoleHeight: CGFloat = 150
    private let wallWidth: CGFloat = 100
    private let playerWidth: CGFloat = 30
    private let playerHeight: CGFloat = 40
    private let playerCornerRadius: CGFloat = 4
    private let playerWalkForceMult: Float = 50
    private let playerJumpImpulseMult = 30
    private let playerGroundDetectionRange: CGFloat = 20
    private var groundLeftNode: SKShapeNode?
    private var groundRightNode: SKShapeNode?
    private var ceilingLeftNode: SKShapeNode?
    private var ceilingRightNode: SKShapeNode?
    private var leftWallTopNode: SKShapeNode?
    private var leftWallBottomNode: SKShapeNode?
    private var rightWallTopNode: SKShapeNode?
    private var rightWallBottomNode: SKShapeNode?
    private var playerNode: SKShapeNode?
    private var playerFeetNode: SKShapeNode?
    private var controller = GCController()

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

    private func addGround() {
        groundLeftNode = SKShapeNode(rectOf: CGSize(width: (frame.width - groundHoleWidth) / 2, height: groundHeight))
        guard let groundLeftNode = groundLeftNode else { return }
        groundLeftNode.position = CGPoint(x: frame.minX + groundLeftNode.frame.width / 2, y: frame.minY)
        groundLeftNode.fillColor = .white
        groundLeftNode.physicsBody = SKPhysicsBody(rectangleOf: groundLeftNode.frame.size)
        groundLeftNode.physicsBody?.isDynamic = false
        addChild(groundLeftNode)

        groundRightNode = SKShapeNode(rectOf: CGSize(width: (frame.width - groundHoleWidth) / 2, height: groundHeight))
        guard let groundRightNode = groundRightNode else { return }
        groundRightNode.position = CGPoint(x: frame.maxX - groundRightNode.frame.width / 2, y: frame.minY)
        groundRightNode.fillColor = .white
        groundRightNode.physicsBody = SKPhysicsBody(rectangleOf: groundRightNode.frame.size)
        groundRightNode.physicsBody?.isDynamic = false
        addChild(groundRightNode)
    }

    private func addCeiling() {
        ceilingLeftNode = SKShapeNode(rectOf: CGSize(width: (frame.width - groundHoleWidth) / 2, height: groundHeight))
        guard let ceilingLeftNode = ceilingLeftNode else { return }
        ceilingLeftNode.position = CGPoint(x: frame.minX + ceilingLeftNode.frame.width / 2, y: frame.maxY)
        ceilingLeftNode.fillColor = .white
        ceilingLeftNode.physicsBody = SKPhysicsBody(rectangleOf: ceilingLeftNode.frame.size)
        ceilingLeftNode.physicsBody?.isDynamic = false
        addChild(ceilingLeftNode)

        ceilingRightNode = SKShapeNode(rectOf: CGSize(width: (frame.width - groundHoleWidth) / 2, height: groundHeight))
        guard let ceilingRightNode = ceilingRightNode else { return }
        ceilingRightNode.position = CGPoint(x: frame.maxX - ceilingRightNode.frame.width / 2, y: frame.maxY)
        ceilingRightNode.fillColor = .white
        ceilingRightNode.physicsBody = SKPhysicsBody(rectangleOf: ceilingRightNode.frame.size)
        ceilingRightNode.physicsBody?.isDynamic = false
        addChild(ceilingRightNode)
    }

    private func addWalls() {
        leftWallTopNode = SKShapeNode(rectOf: CGSize(width: wallWidth, height: (frame.height - wallHoleHeight) / 2))
        guard let leftWallTopNode = leftWallTopNode else { return }
        leftWallTopNode.position = CGPoint(x: frame.minX, y: frame.maxY - leftWallTopNode.frame.height / 2)
        leftWallTopNode.fillColor = .white
        leftWallTopNode.physicsBody = SKPhysicsBody(rectangleOf: leftWallTopNode.frame.size)
        leftWallTopNode.physicsBody?.isDynamic = false
        leftWallTopNode.physicsBody?.restitution = 0
        addChild(leftWallTopNode)

        leftWallBottomNode = SKShapeNode(rectOf: CGSize(width: wallWidth, height: (frame.height - wallHoleHeight) / 2))
        guard let leftWallBottomNode = leftWallBottomNode else { return }
        leftWallBottomNode.position = CGPoint(x: frame.minX, y: frame.minY + leftWallBottomNode.frame.height / 2)
        leftWallBottomNode.fillColor = .white
        leftWallBottomNode.physicsBody = SKPhysicsBody(rectangleOf: leftWallBottomNode.frame.size)
        leftWallBottomNode.physicsBody?.isDynamic = false
        leftWallBottomNode.physicsBody?.restitution = 0
        addChild(leftWallBottomNode)

        rightWallTopNode = SKShapeNode(rectOf: CGSize(width: wallWidth, height: (frame.height - wallHoleHeight) / 2))
        guard let rightWallTopNode = rightWallTopNode else { return }
        rightWallTopNode.position = CGPoint(x: frame.maxX, y: frame.maxY - rightWallTopNode.frame.height / 2)
        rightWallTopNode.fillColor = .white
        rightWallTopNode.physicsBody = SKPhysicsBody(rectangleOf: rightWallTopNode.frame.size)
        rightWallTopNode.physicsBody?.isDynamic = false
        rightWallTopNode.physicsBody?.restitution = 0
        addChild(rightWallTopNode)

        rightWallBottomNode = SKShapeNode(rectOf: CGSize(width: wallWidth, height: (frame.height - wallHoleHeight) / 2))
        guard let rightWallBottomNode = rightWallBottomNode else { return }
        rightWallBottomNode.position = CGPoint(x: frame.maxX, y: frame.minY + rightWallBottomNode.frame.height / 2)
        rightWallBottomNode.fillColor = .white
        rightWallBottomNode.physicsBody = SKPhysicsBody(rectangleOf: rightWallBottomNode.frame.size)
        rightWallBottomNode.physicsBody?.isDynamic = false
        rightWallBottomNode.physicsBody?.restitution = 0
        addChild(rightWallBottomNode)
    }

    private func addPlayer() {
        playerNode = SKShapeNode(rectOf: CGSize(width: playerWidth, height: playerHeight), cornerRadius: playerCornerRadius)
        guard let playerNode = playerNode else { return }
        playerNode.position = CGPoint(x: frame.midX, y: frame.midY)
        playerNode.fillColor = .red
        playerNode.physicsBody = SKPhysicsBody(rectangleOf: playerNode.frame.size)
        playerNode.physicsBody?.restitution = 0
        playerNode.physicsBody?.allowsRotation = false
        playerNode.physicsBody?.friction = 0.5
        playerNode.physicsBody?.linearDamping = 0.9
        addChild(playerNode)

        playerFeetNode = SKShapeNode(rectOf: CGSize(width: playerWidth, height: playerGroundDetectionRange))
        guard let playerFeetNode = playerFeetNode else { return }
        playerFeetNode.position = CGPoint(x: 0, y: -playerNode.frame.height / 2)
        playerNode.addChild(playerFeetNode)
        playerFeetNode.fillColor = .blue.withAlphaComponent(0.3)
    }

    private func teleportPlayerToSceneBounds() {
        guard let playerNode = playerNode else { return }
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

    private func handlePlayerMovement() {
        guard let dx = controller.extendedGamepad?.leftThumbstick.xAxis.value else { return }
        walk(dx: dx)
    }

    private func limitPlayerVelocity() {
        guard let playerVelocity = playerNode?.physicsBody?.velocity else { return }
        playerNode?.physicsBody?.velocity.dx = playerVelocity.dx > 0 ? min(playerVelocity.dx, maxVelocity) : max(playerVelocity.dx, -maxVelocity)
        playerNode?.physicsBody?.velocity.dy = playerVelocity.dy > 0 ? min(playerVelocity.dy, maxVelocity) : max(playerVelocity.dy, -maxVelocity)
    }

    private func setDelegates() {
        controllerManager.delegate = self
    }

    private func walk(dx: Float) {
        guard let physicsBody = playerNode?.physicsBody else { return }
        if physicsBody.velocity.dx >= abs(maxWalkSpeed) { return }
        playerNode?.physicsBody?.applyForce(CGVector(dx: Int(dx * playerWalkForceMult) , dy: 0))
    }

    private func jump() {
        guard let playerFeetNode = playerFeetNode,
              let groundLeftNode = groundLeftNode,
              let groundRightNode = groundRightNode,
              let leftWallBottomNode = leftWallBottomNode,
              let rightWallBottomNode = rightWallBottomNode else { return }

        let isGrounded = playerFeetNode.intersects(groundLeftNode) || playerFeetNode.intersects(groundRightNode) || playerFeetNode.intersects(leftWallBottomNode) || playerFeetNode.intersects(rightWallBottomNode)
        if isGrounded {
            playerNode?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: playerJumpImpulseMult))
        }
    }

    private func addInputHandlers() {
        controller.extendedGamepad?.buttonA.pressedChangedHandler = { (_, _, isPressed) in
            if isPressed {
                self.jump()
            }
        }
    }
}

extension GameScene: ControllerManagerDelegate {
    func didConnect(_ controller: GCController) {
        self.controller = controller
        addInputHandlers()
        print("Did connect controller!")
    }

    func didDisconnectController() {
        print("Did disconnect controller")
    }
}
