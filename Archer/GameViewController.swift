import UIKit
import SpriteKit

final class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let view = view as? SKView,
              let scene = SKScene(fileNamed: "GameScene") else { return }
        view.presentScene(scene)
    }
}
