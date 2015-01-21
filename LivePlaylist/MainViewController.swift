import UIKit
import Cartography

class MainViewController: UIViewController {
  let applicationContext: ApplicationContext
  
  override init() {
    applicationContext = ApplicationContext()
    super.init(nibName: nil, bundle: nil);
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let playlistViewController = PlaylistViewController(applicationContext: applicationContext)
    addChildViewController(playlistViewController)
    view!.addSubview(playlistViewController.view)
    
    let stopButton = UIButton()
    stopButton.setTitle("Stop", forState: .Normal)
    stopButton.backgroundColor = UIColor.redColor()
    stopButton.addTarget(self, action: "stopPlayback", forControlEvents: .TouchUpInside)
    stopButton.titleLabel?.font = UIFont(name: "Avenir", size: 25)
    stopButton.layer.cornerRadius = 3
    view!.addSubview(stopButton)
    
    layout(stopButton) { stop in
      stop.bottom == stop.superview!.bottom - 10
      stop.width == stop.superview!.width - 20
      stop.left == stop.superview!.left + 10
      stop.right == stop.superview!.right - 10
    }
  }
  
  func stopPlayback() {
    applicationContext.oscService.sendMessage(OSCMessage(address: "/live/stop", arguments: []))
  }
}