import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  let window = UIWindow(frame: UIScreen.mainScreen().bounds)
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
   
    window.rootViewController = MainViewController()
    window.backgroundColor = UIColor.whiteColor()
    window.makeKeyAndVisible()
    return true
  }
  
  func applicationWillResignActive(application: UIApplication) {}
  
  func applicationDidEnterBackground(application: UIApplication) {}
  
  func applicationWillEnterForeground(application: UIApplication) {}
  
  func applicationDidBecomeActive(application: UIApplication) {}
  
  func applicationWillTerminate(application: UIApplication) {}
}
