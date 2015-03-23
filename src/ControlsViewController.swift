import UIKit
import Cartography

class ControlsViewController: UIViewController {
  let applicationContext: ApplicationContext
  let serverAddressKey = "SceneLauncher.serverAddress"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let stopButton = UIButton()
    stopButton.setTitle("Stop", forState: .Normal)
    stopButton.titleLabel?.font = UIFont(name: UIConstants.fontName, size: 25)
    stopButton.backgroundColor = UIColor.redColor()
    stopButton.layer.cornerRadius = 3
    stopButton.addTarget(self, action: "stopPlayback", forControlEvents: .TouchUpInside)
    view!.addSubview(stopButton)
    
    let settingsButton = UIButton()
    settingsButton.setTitle("⚙", forState: .Normal)
    settingsButton.titleLabel?.font = UIFont(name: UIConstants.fontName, size: 35)
    settingsButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
    settingsButton.addTarget(self, action: "openSettings", forControlEvents: .TouchUpInside)
    view!.addSubview(settingsButton)

    let blurEffect = UIBlurEffect(style: .Light)
    let blurView = UIVisualEffectView(effect: blurEffect)
    view!.insertSubview(blurView, atIndex: 0)
    
    view!.frame.size.height = 65
    
    layout(stopButton, settingsButton, blurView) { stop, settings, blurView in
      let margin = CGFloat(10)
      
      stop.top == stop.superview!.top + margin
      stop.left == stop.superview!.left + margin
      stop.bottom == stop.superview!.bottom - margin
      
      settings.centerY == stop.centerY
      settings.left == stop.right + margin
      settings.right == settings.superview!.right - margin
      
      blurView.height == stop.superview!.height
      blurView.width == stop.superview!.width
    }
  }
  
  init(applicationContext: ApplicationContext) {
    self.applicationContext = applicationContext
    
    // TODO jari: listen to changes in preferences using RAC?
    let preferences = NSUserDefaults.standardUserDefaults()
    if let serverAddress = preferences.stringForKey(serverAddressKey) {
      println("Got server address from preferences: \(serverAddress)")
      applicationContext.oscService.reconfigureServerAddress(serverAddress)
    }
    super.init(nibName: nil, bundle: nil)
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func stopPlayback() {
    applicationContext.oscService.sendMessage(OSCMessage(address: "/live/stop", arguments: []))
  }
  
  func openSettings() {
    self.navigationController?.pushViewController(
      SettingsViewController(
        currentServerAddress: NSUserDefaults.standardUserDefaults().stringForKey(serverAddressKey),
        settingsSavedCallback: serverAddressChanged
      ),
      animated: true
    )
  }
  
  private func serverAddressChanged(serverAddress: String?) {
    if let newAddress = serverAddress {
      println("Received new server address", serverAddress)
      let preferences = NSUserDefaults.standardUserDefaults()
      preferences.setObject(serverAddress, forKey: serverAddressKey)
      applicationContext.oscService.reconfigureServerAddress(newAddress)
    }
  }
}

