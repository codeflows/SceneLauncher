import ReactiveCocoa

class AbletonTrackService : NSObject, TrackService {
  let osc = OSCService()
  
  func listTracks(callback: ([String]) -> ()) {
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
        .delay(0, onScheduler: QueueScheduler())
      
    let sceneNames : HotSignal<String> = numberOfScenes.mergeMap { n in
      NSLog("Will map \(n) tracks to their names")

      // TODO Start listening to replies before sending the request
      let sceneNameReplies =
        self.osc.incomingMessagesSignal
          .filter { $0.address == "/live/name/scene" }
          .map { $0.arguments[1] as String }

      self.osc.sendMessage(OSCMessage(address: "/live/name/scene", arguments: []))
      
      sceneNameReplies.observe { NSLog("Inner got name \($0)") }

      return sceneNameReplies
    }
    
    // TODO no replies received here!
    sceneNames.observe { NSLog("Got name \($0)") }
  }
}

