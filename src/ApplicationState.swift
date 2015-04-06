import Foundation
import ReactiveCocoa
import LlamaKit

class ApplicationState: NSObject {
  let active: PropertyOf<Bool>
  
  private let mutableActive = MutableProperty<Bool>(false)
  
  override init() {
    active = PropertyOf(mutableActive)
    
    super.init()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "_applicationDidBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "_applicationWillResign", name: UIApplicationWillResignActiveNotification, object: nil)
  }
  
  func _applicationDidBecomeActive() {
    NSLog("[SystemSignals] Application became active")
    mutableActive.put(true)
  }
  
  func _applicationWillResign() {
    NSLog("[SystemSignals] Application will resign")
    mutableActive.put(false)
  }
}