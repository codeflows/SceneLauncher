import UIKit

class MainViewController: UIViewController {
  override init() {
    super.init(nibName: nil, bundle: nil);

    let playlistViewController = PlaylistViewController()
    addChildViewController(playlistViewController)
    view!.addSubview(playlistViewController.view)
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}