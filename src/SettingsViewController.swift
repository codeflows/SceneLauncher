import UIKit
import Cartography

typealias ServerAddressChangedCallback = (String?) -> ()

class SettingsViewController: UIViewController {
  let settingsSavedCallback: ServerAddressChangedCallback
  let serverAddressTextField: UITextField
  
  init(currentServerAddress: String?, settingsSavedCallback: ServerAddressChangedCallback) {
    self.settingsSavedCallback = settingsSavedCallback
    self.serverAddressTextField = UITextField()
    self.serverAddressTextField.text = currentServerAddress
    super.init(nibName: nil, bundle: nil)
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.whiteColor()
    
    let title = UILabel()
    title.text = "Server address"
    title.font = UIFont(name: "Avenir", size: 20)
    view.addSubview(title)
    
    serverAddressTextField.font = UIFont(name: "Avenir", size: 18)
    serverAddressTextField.layer.cornerRadius = 3
    serverAddressTextField.becomeFirstResponder()
    view.addSubview(serverAddressTextField)
    
    let margin = CGFloat(10)
    
    layout(title, serverAddressTextField) { title, serverAddressTextField in
      // TODO would be nice to able to use this: https://github.com/robb/Cartography/issues/95
      title.top == title.superview!.top + 50

      title.left == title.superview!.left + margin
      title.width == title.superview!.width - (2 * margin)

      serverAddressTextField.top == title.bottom + margin
      serverAddressTextField.left == title.left
      serverAddressTextField.width == title.superview!.width - (2 * margin)
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    settingsSavedCallback(serverAddressTextField.text)
  }
}