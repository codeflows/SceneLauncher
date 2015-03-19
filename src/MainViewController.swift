import UIKit
import Cartography

class MainViewController: UIViewController {
  let applicationContext: ApplicationContext
  
  override init() {
    applicationContext = ApplicationContext()
    
    // TODO jari: listen to changes in preferences using RAC?
    let preferences = NSUserDefaults.standardUserDefaults()
    if let serverAddress = preferences.stringForKey("SceneLauncher.serverAddress") {
      println("Got server address from preferences: \(serverAddress)")
      applicationContext.oscService.reconfigureServerAddress(serverAddress)
    }
    super.init(nibName: nil, bundle: nil);
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let sceneViewController = SceneViewController(applicationContext: applicationContext)
    addChildViewController(sceneViewController)
    view!.addSubview(sceneViewController.view)
    
    let stopButton = UIButton()
    stopButton.setTitle("Stop", forState: .Normal)
    stopButton.titleLabel?.font = UIFont(name: "Avenir", size: 25)
    stopButton.backgroundColor = UIColor.redColor()
    stopButton.layer.cornerRadius = 3
    stopButton.addTarget(self, action: "stopPlayback", forControlEvents: .TouchUpInside)
    view!.addSubview(stopButton)

    let settingsButton = UIButton()
    settingsButton.setTitle("⚙", forState: .Normal)
    settingsButton.titleLabel?.font = UIFont(name: "Avenir", size: 45)
    settingsButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
    settingsButton.addTarget(self, action: "openSettings", forControlEvents: .TouchUpInside)
    view!.addSubview(settingsButton)
    
    layout(stopButton, settingsButton) { stop, settings in
      stop.bottom == stop.superview!.bottom - 10
      stop.left == stop.superview!.left + 10
      
      settings.left == stop.right + 10
      settings.right == settings.superview!.right - 10
      // TODO
      settings.bottom == stop.bottom + 14
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    self.navigationController?.setNavigationBarHidden(true, animated: animated)
    super.viewWillAppear(animated)
  }

  override func viewWillDisappear(animated: Bool) {
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
    super.viewWillDisappear(animated)
  }
  
  func stopPlayback() {
    applicationContext.oscService.sendMessage(OSCMessage(address: "/live/stop", arguments: []))
  }
  
  func openSettings() {
    self.navigationController?.pushViewController(
      SettingsViewController(
        currentServerAddress: NSUserDefaults.standardUserDefaults().stringForKey("SceneLauncher.serverAddress"),
        settingsSavedCallback: serverAddressChanged
      ),
      animated: true
    )
  }
  
  private func serverAddressChanged(serverAddress: String?) {
    if let newAddress = serverAddress {
      println("Received new server address", serverAddress)
      let preferences = NSUserDefaults.standardUserDefaults()
      preferences.setObject(serverAddress, forKey: "SceneLauncher.serverAddress")
      applicationContext.oscService.reconfigureServerAddress(newAddress)
    }
  }
}