import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

// Stimulus's eager loader registers controllers via async dynamic
// imports with no signal for "all connected." We wrap every registered
// controller so its connected elements gain a
// `data-<identifier>-loaded="true"` attribute, letting JS-driven tests
// wait for a controller to actually be live before driving it.
const originalRegister = application.register.bind(application)
application.register = (identifier, ControllerClass) => {
  const Wrapped = class extends ControllerClass {
    connect() {
      super.connect()
      this.element.setAttribute(`data-${identifier}-loaded`, "true")
    }

    disconnect() {
      this.element.removeAttribute(`data-${identifier}-loaded`)
      super.disconnect()
    }
  }
  return originalRegister(identifier, Wrapped)
}

export { application }
