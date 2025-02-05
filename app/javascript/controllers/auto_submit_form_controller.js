import { Controller } from "@hotwired/stimulus"
import debounce from "just-debounce"
import { isProduction } from "util/rails_env"

export default class extends Controller {
  submit(event) {
    if (event.target.value.length <= 3) {
      return
    }

    debounce(() => {
      this.element.requestSubmit()
    }, this.timeoutDuration())()
  }

  timeoutDuration() {
    return isProduction() ? 750 : 50;
  }
}
