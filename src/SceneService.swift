import LlamaKit

protocol SceneService {
  func listScenes(callback: (Result<[Scene], NSError>) -> ())
}