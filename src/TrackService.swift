import LlamaKit

protocol TrackService {
  func listTracks(callback: (Result<[Track], NSError>) -> ())
}