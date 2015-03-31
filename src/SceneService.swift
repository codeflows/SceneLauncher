import LlamaKit
import ReactiveCocoa

protocol SceneService {
  func listScenes(callback: ScenesCallback)
}

typealias ScenesCallback = (Result<[Scene], SceneLoadingError>) -> ()

public enum SceneLoadingError {
  case Unknown
  case Timeout
  case ServerError(OSCMessage)
  case NoAddressConfigured
}

extension SceneLoadingError: ErrorType {
  public var nsError: NSError {
    return NSError()
  }
}
