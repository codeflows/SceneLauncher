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
    title.font = UIFont(name: "Avenir", size: 25)
    view.addSubview(title)
    
    let ipAddressTextField = UITextField()
    ipAddressTextField.font = UIFont(name: "Avenir", size: 20)
    view.addSubview(ipAddressTextField)
    
    let helpText = UILabel()
    helpText.text = "Enter the IP address of the computer that's running Ableton Live."
    helpText.font = UIFont(name: "Avenir", size: 16)
    helpText.numberOfLines = 0
    view.addSubview(helpText)

    layout(title, ipAddressTextField, helpText) { title, ipAddressTextField, helpText in
      // TODO hackish way to set top margin
      title.top == title.superview!.top + 40
      title.left == title.superview!.left + 10
      title.width == title.superview!.width - 20
      
      ipAddressTextField.top == title.bottom + 10
      ipAddressTextField.left == title.left
      ipAddressTextField.width == title.width

      helpText.top == ipAddressTextField.bottom + 10
      helpText.left == title.left
      helpText.width == title.width
    }
  }
  
  func dismiss() {
    settingsSavedCallback()
  }
}