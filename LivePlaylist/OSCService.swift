import Foundation
import ReactiveCocoa

class OSCService : NSObject, OSCServerDelegate {
  private let localPort = 9001
  private let client = OSCClient()
  private let server = OSCServer()
  private let incomingMessagesSink : SinkOf<OSCMessage>
  private var serverAddress = "localhost"

  let incomingMessagesSignal : HotSignal<OSCMessage>

  override init() {
    let (signal, sink) = HotSignal<OSCMessage>.pipe()
    incomingMessagesSignal = signal
    incomingMessagesSink = sink

    super.init()
    server.delegate = self
    server.listen(localPort)
  }
  
  func sendMessage(message: OSCMessage) {
    println("[OSCService] Sending message \(message.address): \(message.arguments)")
    client.sendMessage(message, to: "udp://\(serverAddress):9000")
  }
  
  func handleMessage(incomingMessage: OSCMessage!) {
    if let message = incomingMessage {
      println("[OSCService] Received message \(message.address): \(message.arguments)")
      incomingMessagesSink.put(message)
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
