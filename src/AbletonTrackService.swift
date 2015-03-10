import ReactiveCocoa
import LlamaKit

class AbletonTrackService : NSObject, TrackService {
  let osc : OSCService
  
  init(osc: OSCService) {
    self.osc = osc
  }
  
  typealias TracksCallback = (Result<[Track], NSError>) -> ()

  func listTracks(callback: TracksCallback) {
    // TODO currently many requests might be waiting at the same time
    // TODO LiveOsc(?) fails if Scene name contains Unicode characters and returns /remix/error -> short-circuit signal here
    // TODO reliable mechanism for pinging if the server is still reachable
    // TODO refactor: abstraction for sending and receiving message of the same address (e.g. both cases below)

    let numberOfScenes : Signal<Int, NSError> =
      osc.incomingMessagesSignal
        |> filter { $0.address == "/live/scenes" }
        |> take(1)
        |> map { $0.arguments[0] as Int }
        |> timeoutWithError(NSError(), afterInterval: 5, onScheduler: QueueScheduler.mainQueueScheduler)

    osc.sendMessage(OSCMessage(address: "/live/scenes", arguments: []))
    
    // TODO really, we'd like to flatMap the Signal(numberOfScenes) to Signal([Track]) and timeout in one place
    numberOfScenes.observe(next: { expectedNumberOfScenes in
      self.handleTrackListResponse(callback, expectedNumberOfScenes: expectedNumberOfScenes)
      self.osc.sendMessage(OSCMessage(address: "/live/name/scene", arguments: []))
    }, error: { err in
      // TODO
      println("Timeout in number of scenes response")
      callback(failure(err))
    })
  }
  
  private func handleTrackListResponse(callback: TracksCallback, expectedNumberOfScenes: Int) {
    let scenesSignal : Signal<[Track], NSError> =
      osc.incomingMessagesSignal
        |> filter { $0.address == "/live/name/scene" }
        |> take(expectedNumberOfScenes)
        |> map { Track(order: $0.arguments[0] as Int, name: $0.arguments[1] as String) }
        |> scan([], { $0 + [$1] })
        // FIXME ugly: scan returns intermittent results, only choose the last one (use SignalProducer.takeLast?)
        |> filter { $0.count == expectedNumberOfScenes }
        |> take(1)
        |> timeoutWithError(NSError(), afterInterval: 5, onScheduler: QueueScheduler.mainQueueScheduler)
    
    let sortedScenesSignal = scenesSignal |> map { scenes in
      scenes.sorted({$0.order < $1.order})
    }
    
    // TODO handle UI thread stuff in the view controller
    let tempSignal = sortedScenesSignal |> observeOn(UIScheduler())
    tempSignal.observe(
      next: { tracks in callback(success(tracks)) },
      error: { err in println("Timeout in track list response"); callback(failure(err)) }
    )
  }
}

