import Foundation
import ReactiveCocoa
import LlamaKit

class OSCService : NSObject, OSCServerDelegate {
  private let localPort = 9001
  private let client = OSCClient()
  private let server = OSCServer()
  private let incomingMessagesSink : SinkOf<Event<OSCMessage, NoError>>
  private var serverAddress: String?

  let incomingMessagesSignal : Signal<OSCMessage, NoError>

  override init() {
    let (signal, sink) = Signal<OSCMessage, NoError>.pipe()
    incomingMessagesSignal = signal
    incomingMessagesSink = sink

    super.init()
    server.delegate = self
    server.listen(localPort)
  }
  
  func sendMessage(message: OSCMessage) {
    NSLog("[OSCService] Sending message \(message.address): \(message.arguments)")
    client.sendMessage(message, to: "udp://\(serverAddress!):9000")
  }
  
  func handleMessage(incomingMessage: OSCMessage!) {
    if let message = incomingMessage {
      NSLog("[OSCService] Received message \(message.address): \(message.arguments)")
      incomingMessagesSink.put(Event.Next(Box(message)))
    }
  }
  
  func reconfigureServerAddress(address: String) {
    serverAddress = address
    registerWithLiveOSC()
  }
  
  private func registerWithLiveOSC() {
    sendMessage(OSCMessage(address: "/remix/set_peer", arguments: ["", localPort]))
  }
}
