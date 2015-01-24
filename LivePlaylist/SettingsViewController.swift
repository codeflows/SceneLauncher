import UIKit
import Cartography

class SettingsViewController: UIViewController {
  override init() {
    super.init(nibName: nil, bundle: nil);
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let settingsButton = UIButton()
    settingsButton.setTitle("Nappi", forState: .Normal)
    settingsButton.titleLabel?.font = UIFont(name: "Avenir", size: 25)
    settingsButton.backgroundColor = UIColor.grayColor()
    settingsButton.layer.cornerRadius = 3
    settingsButton.addTarget(self, action: "openSettings", forControlEvents: .TouchUpInside)
    view!.addSubview(settingsButton)

    layout(settingsButton) { settings in
      settings.size == settings.superview!.size / 2; return
    }
  }
}