import UIKit
import Cartography

class MainViewController: UIViewController {
  override init() {
    super.init(nibName: nil, bundle: nil);
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let playlistViewController = PlaylistViewController()
    addChildViewController(playlistViewController)
    view!.addSubview(playlistViewController.view)
    
    let stopButton = UIButton()
    stopButton.setTitle("Stop", forState: .Normal)
    stopButton.backgroundColor = UIColor.redColor()
    view!.addSubview(stopButton)
    
    layout(stopButton) { stop in
      stop.bottom == stop.superview!.bottom - 10
      stop.width == stop.superview!.width - 20
      stop.left == stop.superview!.left + 10
      stop.right == stop.superview!.right - 10
    }
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}