class ApplicationContext {
  let systemSignals: SystemSignals
  let oscService: OSCService
  
  init() {
    systemSignals = SystemSignals()
    oscService = OSCService(systemSignals: systemSignals)
  }
}