import ReactiveCocoa

class AbletonTrackService : NSObject, TrackService {
  let osc : OSCService
  
  init(osc: OSCService) {
    self.osc = osc
  }

  func listTracks(callback: ([Track]?) -> ()) {
    // TODO timeout handling for all the requests
    // TODO currently many requests might be waiting at the same time
    // TODO LiveOsc(?) fails if Scene name contains Unicode characters and returns /remix/error
    // TODO reliable mechanism for pinging if the server is still reachable

    let numberOfScenes : Signal<Int, NSError> =
      osc.incomingMessagesSignal
        |> filter { $0.address == "/live/scenes" }
        |> take(1)
        |> map { $0.arguments[0] as Int }
        |> timeoutWithError(NSError(), afterInterval: 5, onScheduler: QueueScheduler.mainQueueScheduler)

    let message = OSCMessage(address: "/live/scenes", arguments: [])
    osc.sendMessage(message)
    
    // TODO really, we'd like to flatMap the Signal(numberOfScenes) to Signal([Track]) and return that
    numberOfScenes.observe(next: { expectedNumberOfScenes in
      let scenesSignal : Signal<[Track], NSError> =
        self.osc.incomingMessagesSignal
          |> filter { $0.address == "/live/name/scene" }
          |> take(expectedNumberOfScenes)
          |> map { Track(order: $0.arguments[0] as Int, name: $0.arguments[1] as String) }
          |> scan([], { $0 + [$1] })
          // FIXME ugly: scan returns intermittent results, only choose the last one (use ColdSignal?)
          |> filter { $0.count == expectedNumberOfScenes }
          |> take(1)
          
      let sortedScenesSignal = scenesSignal |> map { scenes in
        scenes.sorted({$0.order < $1.order})
      }

      self.osc.sendMessage(OSCMessage(address: "/live/name/scene", arguments: []))
      
      // TODO handle UI thread stuff in the view controller
      let tempSignal = sortedScenesSignal |> observeOn(UIScheduler())
      tempSignal.observe(callback)
    }, error: { err in
      // TODO
      println("Error received")
      callback(nil)
    })
  }
}

