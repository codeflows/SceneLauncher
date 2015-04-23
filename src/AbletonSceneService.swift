import ReactiveCocoa
import LlamaKit

class AbletonSceneService : NSObject, SceneService {
  let osc : OSCService
  
  init(osc: OSCService) {
    self.osc = osc
  }
  
  func listScenes() -> SignalProducer<[Scene], SceneLoadingError> {
    if Settings.serverAddress.value == nil {
      return SignalProducer(error: .NoAddressConfigured)
    }
    
    let numberOfScenes = send(OSCMessage(address: "/live/scenes", arguments: []))
      |> handleOSCErrors(timeout: 2)
      |> filter { $0.address == "/live/scenes" }
      |> take(1)
      |> map { $0.arguments[0] as! Int }
    
    return numberOfScenes |> flatMap(.Merge, collectScenes)
  }
  
  private func collectScenes(expectedNumberOfScenes: Int) -> SignalProducer<[Scene], SceneLoadingError> {
    return send(OSCMessage(address: "/live/name/scene", arguments: []))
      |> handleOSCErrors(timeout: 3)
      |> filter { $0.address == "/live/name/scene" }
      |> take(expectedNumberOfScenes)
      |> map(parseSceneFromMessage)
      |> collect
      |> map(sortedByOrder)
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
  
  private func handleOSCErrors(#timeout: NSTimeInterval)(producer: ReactiveCocoa.SignalProducer<OSCMessage, NoError>) -> ReactiveCocoa.SignalProducer<OSCMessage, SceneLoadingError> {
    return producer
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
  
  private func parseSceneFromMessage(message: OSCMessage) -> Scene {
    return Scene(
      order: message.arguments[0] as! Int,
      name: trim(message.arguments[1] as! String)
    )
  }
  
  private func sortedByOrder(scenes: [Scene]) -> [Scene] {
    return scenes.sorted({$0.order < $1.order})
  }
  
  // Scenes are named " 1" etc by default
  private func trim(str: String) -> String {
    return str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
  }
}

