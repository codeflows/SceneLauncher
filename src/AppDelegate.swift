import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  let appWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
   
    application.setStatusBarHidden(true, withAnimation: .Slide)
    
    let navigationController = UINavigationController(rootViewController: MainViewController())

    if let font = UIFont(name: UIConstants.fontName, size: 18) {
      UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName : font], forState: UIControlState.Normal)
    }
    
    appWindow.rootViewController = navigationController
    
    appWindow.backgroundColor = UIColor.whiteColor()
    appWindow.makeKeyAndVisible()
    return true
  }
}

