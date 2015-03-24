import UIKit
import Cartography

typealias ServerAddressChangedCallback = (String?) -> ()

class SettingsViewController: UIViewController, UITextFieldDelegate {
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
    title.font = UIFont(name: UIConstants.fontName, size: 20)
    view.addSubview(title)

    serverAddressTextField.font = UIFont(name: UIConstants.fontName, size: 18)

    // TODO this is retarded
    let padding = UIView(frame: CGRectMake(0, 0, 4, 0))
    serverAddressTextField.leftView = padding;
    serverAddressTextField.leftViewMode = .Always;
    serverAddressTextField.layer.cornerRadius = 3
    serverAddressTextField.backgroundColor = UIColor(white: 0.92, alpha: 1.0)

    serverAddressTextField.becomeFirstResponder()
    serverAddressTextField.returnKeyType = .Done
    serverAddressTextField.delegate = self
    view.addSubview(serverAddressTextField)
    
    let helpText = UITextView()
    helpText.scrollEnabled = false
    helpText.editable = false
    helpText.textContainer.lineFragmentPadding = 0
    helpText.dataDetectorTypes = .Link
    helpText.text =
      "This should be the address of your computer running Ableton Live (with LiveOSC installed.) " +
      "For instructions on how to set up Ableton for use with SceneLauncher, " +
      "please see http://codeflo.ws/SceneLauncher"
    helpText.font = UIFont(name: UIConstants.fontName, size: 13)
    view.addSubview(helpText)
    
    let margin = UIConstants.margin
    
    layout(title, serverAddressTextField, helpText) { title, serverAddressTextField, helpText in
      // TODO would be nice to able to use this: https://github.com/robb/Cartography/issues/95
      title.top == title.superview!.top + 55
      title.left == title.superview!.left + margin
      title.width == title.superview!.width - (2 * margin)
      
      serverAddressTextField.top == title.bottom + margin
      serverAddressTextField.left == title.left
      serverAddressTextField.width == title.width
      serverAddressTextField.height == 30
      
      helpText.top == serverAddressTextField.bottom + margin
      helpText.left == title.left
      helpText.width == title.width
    }
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    settingsSavedCallback(serverAddressTextField.text)
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
