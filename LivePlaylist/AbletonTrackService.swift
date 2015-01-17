import ReactiveCocoa

class AbletonTrackService : NSObject, TrackService {
  let osc = OSCService()

  func listTracks(callback: ([Track]) -> ()) {
    // TODO also start listening for response prior to sending request?
    let message = OSCMessage(address: "/live/scenes", arguments: [])
    osc.sendMessage(message)
    
    // TODO make this time out after an approriate amount of time
    // TODO currently many requests might be waiting at the same time
    // TODO LiveOsc(?) fails if Scene name contains Unicode characters and returns /remix/error
    let numberOfScenes : HotSignal<Int> =
      osc.incomingMessagesSignal
        .filter { $0.address == "/live/scenes" }
        .take(1)
        .map { $0.arguments[0] as Int }

    // Recursive signal deadlocks, so delay the value (https://github.com/ReactiveCocoa/ReactiveCocoa/issues/1670)
    let asyncNumberOfScenes = numberOfScenes.delay(0, onScheduler: QueueScheduler())
      
    let sceneNames : HotSignal<[Track]> = asyncNumberOfScenes.mergeMap { expectedNumberOfScenes in
      let scenesSignal : HotSignal<[Track]> =
        self.osc.incomingMessagesSignal
          .filter { $0.address == "/live/name/scene" }
          .take(expectedNumberOfScenes)
          .map { Track(order: $0.arguments[0] as Int, name: $0.arguments[1] as String) }
          .scan(initial: []) { $0 + [$1] }
          // FIXME ugly: scan returns intermittent results, only choose the last one (use ColdSignal?)
          .filter { $0.count == expectedNumberOfScenes }
          .take(1)
          
      let sortedScenesSignal = scenesSignal.map { scenes in
        scenes.sorted({$0.order < $1.order})
      }

      self.osc.sendMessage(OSCMessage(address: "/live/name/scene", arguments: []))
      
      // TODO handle UI thread stuff in the view controller
      sortedScenesSignal.deliverOn(UIScheduler()).observe(callback)

      return sortedScenesSignal
    }
    
    // TODO fix mergemapping, no replies received here!
    sceneNames.observe { NSLog("Got scene \($0)") }
  }
}

