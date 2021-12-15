import UIKit
import SpriteKit

final class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let view = view as? SKView,
              let scene = SKScene(fileNamed: "GameScene") else { return }
        scene.scaleMode = .resizeFill
        view.ignoresSiblingOrder = true
        view.showsFields = true
        view.showsPhysics = true
        view.showsNodeCount = true
        view.showsFPS = true
        view.preferredFramesPerSecond = 120
        view.presentScene(scene)
    }
}
