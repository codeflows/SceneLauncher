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
    stopButton.bounds = CGRect(x: 100, y: 100, width: 100, height: 10)
    stopButton.backgroundColor = UIColor.redColor()
    view!.addSubview(stopButton)
    
    layout(stopButton) { stop in
      stop.bottom == stop.superview!.bottom; return
    }
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}