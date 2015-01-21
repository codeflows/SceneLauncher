import UIKit

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
    stopButton.setTitleColor(UIColor.redColor(), forState: .Normal)
    stopButton.bounds = CGRect(x: 100, y: 100, width: 100, height: 10)
    view!.addSubview(stopButton)
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}