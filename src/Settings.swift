import Foundation
import ReactiveCocoa

struct Settings {
  private static let serverAddressKey = "SceneLauncher.serverAddress"
  
  // TODO only let non-empty-values out?
  static let serverAddress = { () -> MutableProperty<String?> in
    let property = MutableProperty(NSUserDefaults.standardUserDefaults().stringForKey(serverAddressKey))
    let ignoreInitialValue: SignalProducer<String?, NoError> = property.producer |> skip(1)
    // TODO compiler crashes if we do "producer |> skip |> start"
    ignoreInitialValue.start(next: {
      NSUserDefaults.standardUserDefaults().setObject($0, forKey: serverAddressKey)
    })
    return property
  }()

  // TODO remove
  static func getServerAddress() -> String? {
    return serverAddress.value
  }
  
  static func setServerAddress(newAddress: String) {
    serverAddress.put(newAddress)
  }
}