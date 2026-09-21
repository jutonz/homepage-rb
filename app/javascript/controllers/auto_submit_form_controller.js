import { Controller } from "@hotwired/stimulus"
import { isTest } from "util/rails_env"

export default class extends Controller {
  connect() {
    this.cancel = this.cancel.bind(this)
    this.element.addEventListener("submit", this.cancel)
  }

  disconnect() {
    this.element.removeEventListener("submit", this.cancel)
    this.cancel()
  }

  submit(event) {
    this.cancel()

    const field = event.target
    this.pendingSubmit = setTimeout(() => {
      // The bulk tag dialog empties this field when the viewer selects
      // a tag, and an empty query matches every tag. Read the value
      // here, not before the timer.
      if (field.value.length <= 2) return

      this.element.requestSubmit()
    }, this.timeoutDuration())
  }

  cancel() {
    clearTimeout(this.pendingSubmit)
  }

  timeoutDuration() {
    return isTest() ? 50 : 250;
  }
}
