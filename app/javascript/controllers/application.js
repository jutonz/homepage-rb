import { Application, Controller } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

// Tags the host element with `data-<identifier>-loaded="true"` while
// the controller is connected. Lets JS-driven tests wait for a
// Stimulus controller to actually be live before driving it. We wrap
// the subclass's connect/disconnect at construction time so subclasses
// don't have to remember to call super. (Caveat: this won't fire if a
// subclass declares connect/disconnect as class fields rather than
// methods, since field initializers run after super().)
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
