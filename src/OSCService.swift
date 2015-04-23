import Foundation
import ReactiveCocoa
import LlamaKit

class OSCService : NSObject, OSCServerDelegate {
  private let client = OSCClient()
  private let localServer = OSCServer()
  private let incomingMessagesSink: SinkOf<Event<OSCMessage, NoError>>

  let incomingMessagesSignal: Signal<OSCMessage, NoError>
  
  override init() {
    (incomingMessagesSignal, incomingMessagesSink) = Signal<OSCMessage, NoError>.pipe()

    super.init()

    localServer.delegate = self
    ensureConnected()

    let serverAddressChanges = Settings.serverAddress.producer
      |> skip(1)
      |> ignoreNil
      |> skipRepeats
    
    serverAddressChanges
      |> start(
        next: { _ in self.ensureConnected() },
        error: { _ in () }
      )
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationEnteringForeground", name: UIApplicationWillEnterForegroundNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationEnteringBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
  }

  // OSCService public interface
  
  func sendMessage(message: OSCMessage) {
    if let serverAddress = Settings.serverAddress.value {
      NSLog("[OSCService] Sending message \(message)")
      client.sendMessage(message, to: "udp://\(serverAddress):9000")
    } else {
      NSLog("[OSCService] WARNING: Server address not configured, not sending message \(message)")
    }
  }
  
  func handleMessage(incomingMessage: OSCMessage!) {
    if let message = incomingMessage {
      if shouldLog(message) {
        NSLog("[OSCService] Received message \(message)")
      }
      incomingMessagesSink.put(Event.Next(Box(message)))
    }
  }
  
  func ensureConnected() {
    // TODO This is currently public so that we can call it when manually refreshing scenes.
    //      Ideally, connections would be automatically kept alive in the background.
    NSLog("[OSCService] Ensuring we're able to communicate with Ableton at \(Settings.serverAddress.value)")
    startLocalServerIfNecessary()
    registerWithLiveOSC()
  }
  
  // OSCServer callback
  
  func handleDisconnect(error: NSError!) {
    NSLog("[OSCService] Local UDP server socket was disconnected: Error: \(error)")
  }
  
  // NSNotificationCenter handlers
  
  func applicationEnteringForeground() {
    NSLog("[OSCService] Application entering foreground, starting local UDP server")
    ensureConnected()
  }
  
  func applicationEnteringBackground() {
    NSLog("[OSCService] Application entering background, stopping local UDP server")
    stopLocalServer()
  }
  
  // Private members
  
  private func startLocalServerIfNecessary() {
    if(localServer.isClosed()) {
      localServer.listen(0)
      NSLog("[OSCService] Started local server on port \(localServer.getPort())")
    } else {
      NSLog("[OSCService] Local server already running at port \(localServer.getPort())")
    }
  }
  
  private func stopLocalServer() {
    localServer.stop()
  }
  
  private func registerWithLiveOSC() {
    sendMessage(OSCMessage(address: "/remix/set_peer", arguments: ["", localServer.getPort()]))
  }
  
  private func shouldLog(message: OSCMessage) -> Bool {
    return message.address != "/live/track/meter" && message.address != "/live/device/param"
  }
}

extension OSCMessage: Printable {
  override public var description: String {
    return "\(address) \(arguments)"
  }
}