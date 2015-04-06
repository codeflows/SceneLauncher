import Foundation
import ReactiveCocoa

struct Settings {
  private static let serverAddressKey = "SceneLauncher.serverAddress"
  
  // TODO only let non-empty-values out?
  static let serverAddress = MutableProperty(NSUserDefaults.standardUserDefaults().stringForKey(serverAddressKey))

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