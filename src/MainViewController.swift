import UIKit
import Cartography

class MainViewController: UIViewController {
  let applicationContext: ApplicationContext
  
  init() {
    applicationContext = ApplicationContext()
    super.init(nibName: nil, bundle: nil);
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let sceneViewController = SceneViewController(applicationContext: applicationContext)
    addChildViewController(sceneViewController)
    view!.addSubview(sceneViewController.view)

    let controlsViewController = ControlsViewController(applicationContext: applicationContext)
    addChildViewController(controlsViewController)
    view!.addSubview(controlsViewController.view)
    
    layout(controlsViewController.view) { controls in
      controls.width == controls.superview!.width
      controls.height == UIConstants.controlsHeight
      controls.bottom == controls.superview!.bottom
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    self.navigationController?.setNavigationBarHidden(true, animated: animated)
    super.viewWillAppear(animated)
  }

  override func viewWillDisappear(animated: Bool) {
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
    super.viewWillDisappear(animated)
  }
}