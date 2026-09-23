import UIKit

final class VictimViewController: UIViewController {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let screen = UIScreen.main.bounds
        let pad = view.safeAreaInsets.top * 2
        view.frame = CGRect(x: 0, y: 0, width: 200, height: 400)
        view.bounds.size.width = 390
        if traitCollection.userInterfaceIdiom == .phone {}
        if UIDevice.current.orientation == .portrait {}
        _ = (screen, pad)
    }
}
