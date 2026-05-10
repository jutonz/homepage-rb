import { Application, Controller } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

class BaseController extends Controller {
  constructor(...args) {
    super(...args)

    const userConnect = this.connect.bind(this)
    const userDisconnect = this.disconnect.bind(this)

    this.connect = () => {
      this.element.setAttribute(`data-${this.identifier}-loaded`, "true")
      userConnect()
    }

    this.disconnect = () => {
      userDisconnect()
      this.element.removeAttribute(`data-${this.identifier}-loaded`)
    }
  }
}

export { application, BaseController }
