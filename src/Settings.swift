import Foundation
import ReactiveCocoa

struct Settings {
  private static let serverAddressKey = "SceneLauncher.serverAddress"
  
  static let serverAddress = { () -> MutableProperty<String?> in
    let property = MutableProperty(NSUserDefaults.standardUserDefaults().stringForKey(serverAddressKey))
    // TODO empty error block is needed to prevent Swift compiler crash https://github.com/ReactiveCocoa/ReactiveCocoa/issues/1829
    property.producer |> skip(1) |> start(next: {
      NSUserDefaults.standardUserDefaults().setObject($0, forKey: serverAddressKey)
    }, error: { error in () })
    return property
  }()
}