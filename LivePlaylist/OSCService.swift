import Foundation
import ReactiveCocoa

class OSCService : NSObject, OSCServerDelegate {
  private let client = OSCClient()
  private let server = OSCServer()
  private let incomingMessagesSink : SinkOf<OSCMessage>

  let incomingMessagesSignal : HotSignal<OSCMessage>

  override init() {
    let (signal, sink) = HotSignal<OSCMessage>.pipe()
    incomingMessagesSignal = signal
    incomingMessagesSink = sink

    super.init()
    server.delegate = self
    server.listen(9001)
  }
  
  func sendMessage(message: OSCMessage) {
    client.sendMessage(message, to: "udp://localhost:9000")
  }
  
  func handleMessage(incomingMessage: OSCMessage!) {
    if let message = incomingMessage {
      println("[OSCService] Received message #\(message.address): \(message.arguments)")
      incomingMessagesSink.put(message)
    }
  }
}
