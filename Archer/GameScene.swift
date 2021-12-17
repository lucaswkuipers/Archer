import SpriteKit
import GameController

final class GameScene: SKScene {
    private let maxVelocity: CGFloat = 1_000
    private let groundHoleWidth: CGFloat = 150
    private let groundHeight: CGFloat = 100
    private let wallHoleHeight: CGFloat = 150
    private let wallWidth: CGFloat = 100
    private let playerWidth: CGFloat = 30
    private let playerHeight: CGFloat = 40
    private let playerCornerRadius: CGFloat = 4
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

    override func didMove(to view: SKView) {
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

        leftWallTopNode = SKShapeNode(rectOf: CGSize(width: wallWidth, height: (frame.height - wallHoleHeight) / 2))
        guard let leftWallTopNode = leftWallTopNode else { return }
        leftWallTopNode.position = CGPoint(x: frame.minX, y: frame.maxY - leftWallTopNode.frame.height / 2)
        leftWallTopNode.fillColor = .white
        leftWallTopNode.physicsBody = SKPhysicsBody(rectangleOf: leftWallTopNode.frame.size)
        leftWallTopNode.physicsBody?.isDynamic = false
        addChild(leftWallTopNode)

        leftWallBottomNode = SKShapeNode(rectOf: CGSize(width: wallWidth, height: (frame.height - wallHoleHeight) / 2))
        guard let leftWallBottomNode = leftWallBottomNode else { return }
        leftWallBottomNode.position = CGPoint(x: frame.minX, y: frame.minY + leftWallBottomNode.frame.height / 2)
        leftWallBottomNode.fillColor = .white
        leftWallBottomNode.physicsBody = SKPhysicsBody(rectangleOf: leftWallBottomNode.frame.size)
        leftWallBottomNode.physicsBody?.isDynamic = false
        addChild(leftWallBottomNode)

        rightWallTopNode = SKShapeNode(rectOf: CGSize(width: wallWidth, height: (frame.height - wallHoleHeight) / 2))
        guard let rightWallTopNode = rightWallTopNode else { return }
        rightWallTopNode.position = CGPoint(x: frame.maxX, y: frame.maxY - rightWallTopNode.frame.height / 2)
        rightWallTopNode.fillColor = .white
        rightWallTopNode.physicsBody = SKPhysicsBody(rectangleOf: rightWallTopNode.frame.size)
        rightWallTopNode.physicsBody?.isDynamic = false
        addChild(rightWallTopNode)

        rightWallBottomNode = SKShapeNode(rectOf: CGSize(width: wallWidth, height: (frame.height - wallHoleHeight) / 2))
        guard let rightWallBottomNode = rightWallBottomNode else { return }
        rightWallBottomNode.position = CGPoint(x: frame.maxX, y: frame.minY + rightWallBottomNode.frame.height / 2)
        rightWallBottomNode.fillColor = .white
        rightWallBottomNode.physicsBody = SKPhysicsBody(rectangleOf: rightWallBottomNode.frame.size)
        rightWallBottomNode.physicsBody?.isDynamic = false
        addChild(rightWallBottomNode)

        playerNode = SKShapeNode(rectOf: CGSize(width: playerWidth, height: playerHeight), cornerRadius: playerCornerRadius)
        guard let playerNode = playerNode else { return }
        playerNode.position = CGPoint(x: frame.midX, y: frame.midY)
        playerNode.fillColor = .red
        playerNode.physicsBody = SKPhysicsBody(rectangleOf: playerNode.frame.size)
        addChild(playerNode)
    }

    override func update(_ currentTime: TimeInterval) {
        guard let playerNode = playerNode else { return }
        if playerNode.position.x >= frame.maxX + playerNode.frame.width / 2 {
            playerNode.position.x = frame.minX
        } else if playerNode.position.x <= frame.minX - playerNode.frame.width / 2 {
            playerNode.position.x = frame.maxX
        }

        if playerNode.position.y >= frame.maxY + playerNode.frame.height / 2 {
            playerNode.position.y = frame.minY
        } else if playerNode.position.y <= frame.minY {
            playerNode.position.y = frame.maxY
        }

        guard let playerVelocity = playerNode.physicsBody?.velocity else { return }

        playerNode.physicsBody?.velocity.dx = playerVelocity.dx > 0 ? min(playerVelocity.dx, maxVelocity) : max(playerVelocity.dx, -maxVelocity)

        playerNode.physicsBody?.velocity.dy = playerVelocity.dy > 0 ? min(playerVelocity.dy, maxVelocity) : max(playerVelocity.dy, -maxVelocity)
    }
}
