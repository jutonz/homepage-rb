import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.handleLoad = this.restoreFocus.bind(this)
    document.addEventListener("turbo:load", this.handleLoad)
    this.restoreFocus()
  }

  disconnect() {
    document.removeEventListener("turbo:load", this.handleLoad)
  }

  restoreFocus() {
    if (this.element.value) this.element.focus()
  }
}
