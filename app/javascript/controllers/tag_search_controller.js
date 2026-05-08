import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["results"]

  submitFirstResult(event) {
    if (event.key !== "Enter") return

    const result = this.resultsTarget.querySelector(
      "[data-role='tag-search-result']"
    )
    if (!result) return

    const form = result.querySelector("form")
    if (!form) return

    event.preventDefault()
    const input = event.target
    form.requestSubmit()
    input.value = ""
    input.focus()
  }
}
