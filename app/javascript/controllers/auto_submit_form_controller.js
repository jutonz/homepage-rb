import { Controller } from "@hotwired/stimulus"
import { isProduction } from "../util/rails_env"

export default class extends Controller {
  submit(event) {
    if (event.target.value.length <= 3) {
      return
    }

    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, this.timeoutDuration())
  }

  timeoutDuration() {
    return isProduction() ? 750 : 50;
  }
}
