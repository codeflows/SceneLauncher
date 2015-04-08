import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  let window = UIWindow(frame: UIScreen.mainScreen().bounds)
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
   
    application.setStatusBarHidden(true, withAnimation: .Slide)
    
    let navigationController = UINavigationController(rootViewController: MainViewController())

    if let font = UIFont(name: UIConstants.fontName, size: 18) {
      UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName : font], forState: UIControlState.Normal)
    }
    
    window.rootViewController = navigationController
    
    window.backgroundColor = UIColor.whiteColor()
    window.makeKeyAndVisible()
    return true
  }
}

