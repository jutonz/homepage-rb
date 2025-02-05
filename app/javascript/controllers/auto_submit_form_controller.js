import { Controller } from "@hotwired/stimulus"
import debounce from "just-debounce"
import { isTest } from "util/rails_env"

export default class extends Controller {
  connect() {
    this.debouncedSubmit = debounce((event) => {
      if (event.target.value.length > 3) {
        this.element.requestSubmit()
      }
    }, this.timeoutDuration())
  }

  submit(event) {
    this.debouncedSubmit(event)
  }

  timeoutDuration() {
    return isTest() ? 50 : 250;
  }
}
