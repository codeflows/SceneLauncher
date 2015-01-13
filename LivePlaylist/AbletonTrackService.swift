import ReactiveCocoa

class AbletonTrackService : NSObject, TrackService {
  let osc = OSCService()
  
  func listTracks(callback: ([String]) -> ()) {
    let message = OSCMessage(address: "/live/scenes", arguments: [])
    osc.sendMessage(message)
    
    // TODO make this time out after an approriate amount of time
    // TODO LiveOsc(?) fails if Scene name contains Unicode characters and returns /remix/error
    let numberOfScenes : HotSignal<Int> =
      osc.incomingMessagesSignal
        .filter { $0.address == "/live/scenes" }
        .take(1)
        .map { $0.arguments[0] as Int }
        // Recursive signal deadlocks, so delay the value (https://github.com/ReactiveCocoa/ReactiveCocoa/issues/1670)
       

    let sceneNames : HotSignal<String> = numberOfScenes.mergeMap { n in
      NSLog("Will map \(n) tracks to their names")

      // Start listening to replies before sending the request
      let sceneNameReplies =
        self.osc.incomingMessagesSignal
          .filter { $0.address == "/live/name/scene" }
          .map { $0.arguments[1] as String }

      self.osc.sendMessage(OSCMessage(address: "/live/name/scene", arguments: []))

      return sceneNameReplies
    }
    
    sceneNames.observe { NSLog("Got name \($0)") }
    
    /*let x : HotSignal<OSCMessage> = numberOfScenes.mergeMap { n in
      NSLog("BOOM! Getting names for \(n) scenes")
      osc.sendMessage(OSCMessage(address: "/live/name/scene", arguments: []))
      return osc.incomingMessagesSignal
        .filter { $0.address == "/live/name/scene" }
        .observe { NSLog("  Got scene #\($0.arguments[0]): \($0.arguments[1])") }
    }*/
  }
}

