import GameController

protocol ControllerManagerDelegate: AnyObject {
    func didConnect(_ controller: GCController)
    func didDisconnectController()
}

final class ControllerManager {
    weak var delegate: ControllerManagerDelegate?

    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didConnectController),
                                               name: .GCControllerDidConnect,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didDisconnectController),
                                               name: .GCControllerDidDisconnect,
                                               object: nil)
    }

    @objc private func didConnectController() {
        guard let controller = GCController.controllers().first else { return }
        delegate?.didConnect(controller)
    }

    @objc private func didDisconnectController() {
        delegate?.didDisconnectController()
    }
}
