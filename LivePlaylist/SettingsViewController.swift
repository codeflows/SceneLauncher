import UIKit
import Cartography

class SettingsViewController: UIViewController {
  let settingsSavedCallback: () -> ()
  
  init(settingsSavedCallback: () -> ()) {
    self.settingsSavedCallback = settingsSavedCallback
    super.init(nibName: nil, bundle: nil)
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let title = UILabel()
    title.text = "Server address"
    view.addSubview(title)
    
    let ipAddressTextField = UITextField()
    ipAddressTextField.text = "192.168.0.1"
    view.addSubview(ipAddressTextField)
    
    let helpText = UILabel()
    helpText.text = "Enter the IP address of the computer that's running Ableton Live."
    view.addSubview(helpText)

    layout(title, ipAddressTextField, helpText) { title, ipAddressTextField, helpText in
      // TODO hackish way to set top margin
      title.top == title.superview!.top + 40
      ipAddressTextField.top == title.bottom + 10
      helpText.top == ipAddressTextField.bottom + 10
    }
  }
  
  func dismiss() {
    settingsSavedCallback()
  }
}