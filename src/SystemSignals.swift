import Foundation
import ReactiveCocoa
import LlamaKit

class SystemSignals: NSObject {
  let applicationWillResignSignal: Signal<(), NoError>
  let applicationDidBecomeActiveSignal: Signal<(), NoError>

  private let resignSink: SinkOf<Event<(), NoError>>
  private let activeSink: SinkOf<Event<(), NoError>>

  override init() {
    (applicationWillResignSignal, resignSink) = Signal<(), NoError>.pipe()
    (applicationDidBecomeActiveSignal, activeSink) = Signal<(), NoError>.pipe()
    
    super.init()
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "_applicationDidBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "_applicationWillResign", name: UIApplicationWillResignActiveNotification, object: nil)
  }
  
  func _applicationDidBecomeActive() {
    NSLog("[SystemSignals] Application became active")
    activeSink.put(Event.Next(Box(())))
  }
  
  func _applicationWillResign() {
    NSLog("[SystemSignals] Application will resign")
    resignSink.put(Event.Next(Box(())))  }
}