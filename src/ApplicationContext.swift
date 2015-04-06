class ApplicationContext {
  let applicationState: ApplicationState
  let oscService: OSCService
  
  init() {
    applicationState = ApplicationState()
    oscService = OSCService(applicationState: applicationState)
  }
}