import SpriteKit

final class GameScene: SKScene {
    let ground: SKNode = {
        let node = SKShapeNode(rectOf: CGSize(width: 1000, height: 100))
        node.name = "ground"
        node.physicsBody = SKPhysicsBody(rectangleOf: node.frame.size)
        node.physicsBody?.isDynamic = false
        node.fillColor = .white
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
