import Foundation
import ReactiveCocoa

struct Settings {
  private static let serverAddressKey = "SceneLauncher.serverAddress"
  
  // TODO only let non-empty-values out?
  static let serverAddress = { () -> MutableProperty<String?> in
    let property = MutableProperty(NSUserDefaults.standardUserDefaults().stringForKey(serverAddressKey))
    let ignoreInitialValue: SignalProducer<String?, NoError> = property.producer |> skip(1)
    ignoreInitialValue.start(next: { println("Yes sir got \($0)") })
    return property
  }()

  // TODO remove
  static func getServerAddress() -> String? {
    return serverAddress.value
  }
  
  static func setServerAddress(newAddress: String) {
    serverAddress.put(newAddress)
    // TODO do this when serverAddress changes
    NSUserDefaults.standardUserDefaults().setObject(newAddress, forKey: serverAddressKey)
  }
}