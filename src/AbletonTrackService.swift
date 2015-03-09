import ReactiveCocoa

class AbletonTrackService : NSObject, TrackService {
  let osc : OSCService
  
  init(osc: OSCService) {
    self.osc = osc
  }

  func listTracks(callback: ([Track]) -> ()) {
    // TODO make this time out after an approriate amount of time
    // TODO currently many requests might be waiting at the same time
    // TODO LiveOsc(?) fails if Scene name contains Unicode characters and returns /remix/error
    let numberOfScenes : Signal<Int, NoError> =
      osc.incomingMessagesSignal
        |> filter { $0.address == "/live/scenes" }
        |> take(1)
        |> map { $0.arguments[0] as Int }

    let message = OSCMessage(address: "/live/scenes", arguments: [])
    osc.sendMessage(message)
    
    // TODO really, we'd like to flatMap the Signal(numberOfScenes) to Signal([Track]) and return that
    numberOfScenes.observe(next: { expectedNumberOfScenes in
      let scenesSignal : Signal<[Track], NoError> =
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
    })
  }
}

