import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["results", "query"]

  clearQuery() {
    this.queryTarget.value = ""
    this.queryTarget.focus()
  }

  submitFirstResult(event) {
    if (event.key !== "Enter") return

    const result = this.resultsTarget.querySelector(
      "[data-role='tag-search-result']"
    )
    if (!result) return

    const form = result.querySelector("form")
    if (!form) return

    event.preventDefault()
    form.requestSubmit()
    this.clearQuery()
  }
}
