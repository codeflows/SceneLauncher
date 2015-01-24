import UIKit
import Cartography

typealias IpAddressChangedCallback = (String?) -> ()

class SettingsViewController: UIViewController {
  let settingsSavedCallback: IpAddressChangedCallback
  let ipAddressTextField: UITextField
  
  init(settingsSavedCallback: IpAddressChangedCallback) {
    self.settingsSavedCallback = settingsSavedCallback
    self.ipAddressTextField = UITextField()
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
    
    ipAddressTextField.font = UIFont(name: "Avenir", size: 20)
    ipAddressTextField.becomeFirstResponder()
    view.addSubview(ipAddressTextField)
    
    let saveButton = UIButton()
    saveButton.setTitle("Save", forState: .Normal)
    saveButton.titleLabel?.font = UIFont(name: "Avenir", size: 20)
    saveButton.backgroundColor = UIColor.grayColor()
    saveButton.layer.cornerRadius = 3
    saveButton.addTarget(self, action: "dismiss", forControlEvents: .TouchUpInside)
    view.addSubview(saveButton)

    layout(title, ipAddressTextField, saveButton) { title, ipAddressTextField, saveButton in
      // TODO hackish way to set top margin
      title.top == title.superview!.top + 40
      title.left == title.superview!.left + 10
      title.width == title.superview!.width - 20
      
      ipAddressTextField.top == title.bottom + 10
      ipAddressTextField.left == title.left
      
      saveButton.left == ipAddressTextField.right + 10
      saveButton.right == title.right
      saveButton.baseline == ipAddressTextField.baseline
    }
  }
  
  func dismiss() {
    settingsSavedCallback(ipAddressTextField.text)
  }
}