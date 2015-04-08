import LlamaKit
import ReactiveCocoa

protocol SceneService {
  func listScenes() -> SignalProducer<[Scene], SceneLoadingError>
}

public enum SceneLoadingError {
  case Unknown
  case Timeout
  case LiveOsc(String)
  case NoAddressConfigured
}

extension SceneLoadingError: ErrorType {
  public var nsError: NSError {
    return NSError()
  }
}
