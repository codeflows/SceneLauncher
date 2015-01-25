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
    
    let saveButton = UIButton()
    saveButton.setTitle("Save", forState: .Normal)
    saveButton.titleLabel?.font = UIFont(name: "Avenir", size: 20)
    saveButton.backgroundColor = UIColor.grayColor()
    saveButton.layer.cornerRadius = 3
    saveButton.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
    view.addSubview(saveButton)

    layout(title, serverAddressTextField, saveButton) { title, serverAddressTextField, saveButton in
      // TODO hackish way to set top margin
      title.top == title.superview!.top + 40
      title.left == title.superview!.left + 10
      title.width == title.superview!.width - 20
      
      serverAddressTextField.top == title.bottom + 10
      serverAddressTextField.left == title.left
      
      saveButton.left == serverAddressTextField.right + 10
      saveButton.right == title.right
      saveButton.baseline == serverAddressTextField.baseline
    }
  }
  
  func dismiss() {
    settingsSavedCallback(serverAddressTextField.text)
  }
}