import Foundation

struct SettingsRepository {
  static let serverAddressKey = "SceneLauncher.serverAddress"

  static func getServerAddress() -> String? {
    return NSUserDefaults.standardUserDefaults().stringForKey(serverAddressKey)
  }
  
  static func setServerAddress(newAddress: String) {
    NSUserDefaults.standardUserDefaults().setObject(newAddress, forKey: serverAddressKey)
  }
}