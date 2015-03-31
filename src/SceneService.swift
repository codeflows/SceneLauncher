import LlamaKit
import ReactiveCocoa

protocol SceneService {
  func listScenes(callback: ScenesCallback)
}

typealias ScenesCallback = (Result<[Scene], SceneLoadingError>) -> ()

public enum SceneLoadingError {
  case Timeout(String)
  case NoAddressConfigured
}

extension SceneLoadingError: ErrorType {
  public var nsError: NSError {
    return NSError()
  }
}
