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
    title.font = UIFont(name: "Avenir", size: 25)
    view.addSubview(title)
    
    serverAddressTextField.font = UIFont(name: "Avenir", size: 20)
    serverAddressTextField.becomeFirstResponder()
    view.addSubview(serverAddressTextField)
    
    layout(title, serverAddressTextField) { title, serverAddressTextField in
      // TODO would be nice to able to use this: https://github.com/robb/Cartography/issues/95
      title.top == title.superview!.top + 50

      title.left == title.superview!.left + 10
      title.width == title.superview!.width - 20

      serverAddressTextField.top == title.bottom + 10
      serverAddressTextField.left == title.left
      serverAddressTextField.width == title.superview!.width - 20
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    settingsSavedCallback(serverAddressTextField.text)
  }
}