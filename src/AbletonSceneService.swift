import ReactiveCocoa
import LlamaKit

class AbletonSceneService : NSObject, SceneService {
  let osc : OSCService
  
  init(osc: OSCService) {
    self.osc = osc
  }
  
  func listScenes() -> SignalProducer<[Scene], SceneLoadingError> {
    // TODO currently many requests might be waiting at the same time
    // TODO reliable mechanism for pinging if the server is still reachable

    if Settings.serverAddress.value == nil {
      return SignalProducer(error: .NoAddressConfigured)
    }
    
    let reply = send(OSCMessage(address: "/live/scenes", arguments: []))
    
    let numberOfScenes : SignalProducer<Int, SceneLoadingError> =
      incomingMessages(reply, timeout: 2)
        |> filter { $0.address == "/live/scenes" }
        |> take(1)
        |> map { $0.arguments[0] as! Int }

    return numberOfScenes |> flatMap(.Merge, handleSceneListResponse)
  }
  
  private func handleSceneListResponse(expectedNumberOfScenes: Int) -> SignalProducer<[Scene], SceneLoadingError> {
    let replies = send(OSCMessage(address: "/live/name/scene", arguments: []))
    
    let scenesSignal : SignalProducer<[Scene], SceneLoadingError> =
      incomingMessages(replies, timeout: 3)
        |> filter { $0.address == "/live/name/scene" }
        |> take(expectedNumberOfScenes)
        |> map { Scene(order: $0.arguments[0] as! Int, name: self.trim($0.arguments[1] as! String)) }
        // FIXME this seems to crash now - but usually on 2nd run. Are we leaking something?
        |> collect
    
    let sortedScenesSignal = scenesSignal |> map { scenes in
      scenes.sorted({$0.order < $1.order})
    }
    
    // TODO handle UI thread stuff in the view controller
    return sortedScenesSignal
      |> observeOn(UIScheduler())
  }
  
  private func incomingMessages(replies: SignalProducer<OSCMessage, NoError>, timeout: NSTimeInterval) -> SignalProducer<OSCMessage, SceneLoadingError> {
    return replies
      |> mapError { _ in .Unknown }
      |> try { message in
        if(message.address == "/remix/error") {
          return failure(.LiveOsc(self.parseLiveOSCErrorReason(message)))
        }
        return success()
      }
      |> timeoutWithError(.Timeout, afterInterval: timeout, onScheduler: QueueScheduler.mainQueueScheduler)
  }
  
  private func parseLiveOSCErrorReason(message: OSCMessage) -> String {
    if(message.arguments.count == 1 && message.arguments[0] is String) {
      let errorMessage = message.arguments[0] as! String
      
      if errorMessage.rangeOfString("UnicodeEncodeError") != nil {
        return "Unicode error: LiveOSC doesn't support special unicode characters, please check your scene names."
      }
    }
    return "Unknown error from LiveOSC"
  }
  
  // Scenes are named " 1" etc by default
  private func trim(str: String) -> String {
    return str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
  }
  
  private func send(message: OSCMessage) -> SignalProducer<OSCMessage, NoError> {
    return SignalProducer { observer, producerDisposed in
      // Start listening to replies right away, before sending request
      let replyDisposable = self.osc.incomingMessagesSignal.observe(observer)
      
      // Stop listening to replies when this producer is disposed
      producerDisposed.addDisposable(replyDisposable)
      
      // Send request
      self.osc.sendMessage(message)
    }
  }
}

