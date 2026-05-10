import { Controller } from "@hotwired/stimulus"

// Reloads the host turbo-frame whenever document.visibilityState
// transitions to "visible". Used so backgrounded image-show tabs
// pick up freshly tagged data the moment the user returns to them,
// without needing to refresh the page manually.
export default class extends Controller {
  connect() {
    this.boundRefresh = this.refresh.bind(this)
    document.addEventListener("visibilitychange", this.boundRefresh)
  }

  disconnect() {
    document.removeEventListener("visibilitychange", this.boundRefresh)
  }

  refresh() {
    if (document.visibilityState !== "visible") return
    if (typeof this.element.reload !== "function") return
    this.element.reload()
  }
}
