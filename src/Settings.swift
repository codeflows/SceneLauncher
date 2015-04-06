import Foundation
import ReactiveCocoa

struct Settings {
  private static let serverAddressKey = "SceneLauncher.serverAddress"
  
  static let serverAddress = { () -> MutableProperty<String?> in
    let property = MutableProperty(NSUserDefaults.standardUserDefaults().stringForKey(serverAddressKey))
    let ignoreInitialValue: SignalProducer<String?, NoError> = property.producer |> skip(1)
    // TODO compiler crashes if we do "producer |> skip |> start"
    ignoreInitialValue.start(next: {
      NSUserDefaults.standardUserDefaults().setObject($0, forKey: serverAddressKey)
    })
    return property
  }()
}