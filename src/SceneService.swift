import LlamaKit

typealias ScenesCallback = (Result<[Scene], NSError>) -> ()

protocol SceneService {
  func listScenes(callback: ScenesCallback)
}