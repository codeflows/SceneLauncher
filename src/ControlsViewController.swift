import UIKit
import Cartography

class ControlsViewController: UIViewController {
  let applicationContext: ApplicationContext
  
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
    settingsButton.setTitleColor(UIColor(white: 0.92, alpha: 1.0), forState: .Normal)
    settingsButton.addTarget(self, action: "openSettings", forControlEvents: .TouchUpInside)
    view!.addSubview(settingsButton)

    if Settings.serverAddress.value == nil {
      pulsate(settingsButton)
    }

    let blurEffect = UIBlurEffect(style: .Dark)
    let blurView = UIVisualEffectView(effect: blurEffect)
    view!.insertSubview(blurView, atIndex: 0)
    
    layout(stopButton, settingsButton, blurView) { stop, settings, blurView in
      let margin = UIConstants.margin
      
      stop.top == stop.superview!.top + margin
      stop.left == stop.superview!.left + margin
      stop.bottom == stop.superview!.bottom - margin
      
      settings.centerY == stop.centerY
      settings.left == stop.right + margin
      settings.right == settings.superview!.right - margin
      
      blurView.top == stop.superview!.top
      blurView.height == stop.superview!.height
      blurView.width == stop.superview!.width
    }
  }
  
  init(applicationContext: ApplicationContext) {
    self.applicationContext = applicationContext
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
        currentServerAddress: Settings.serverAddress.value,
        settingsSavedCallback: serverAddressChanged
      ),
      animated: true
    )
  }
  
  private func serverAddressChanged(serverAddress: String?) {
    if let newAddress = serverAddress {
      NSLog("Received new server address", newAddress)
      Settings.serverAddress.put(newAddress)
    }
  }
  
  private func pulsate(view: UIView) {
    let pulsatingAnimation = CABasicAnimation(keyPath: "transform.scale")
    pulsatingAnimation.fromValue = 1.0
    pulsatingAnimation.toValue = 1.3
    pulsatingAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
    pulsatingAnimation.duration = 0.5
    pulsatingAnimation.autoreverses = true
    pulsatingAnimation.repeatCount = 5
    view.layer.addAnimation(pulsatingAnimation, forKey: nil)
  }
}

