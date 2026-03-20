import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["results"]

  submitFirstResult(event) {
    if (event.key !== "Enter") return

    const result = this.resultsTarget.querySelector(
      "[data-role='tag-search-result']"
    )
    if (!result) return

    event.preventDefault()

    const input = event.target
    const query = input.value

    const form = result.querySelector("form")
    if (!form) return

    const abortController = new AbortController()
    const timeout = setTimeout(
      () => abortController.abort(),
      10000
    )

    document.addEventListener(
      "turbo:before-stream-render",
      (renderEvent) => {
        const streamEl = renderEvent.target
        if (streamEl.getAttribute("target") !== "tag-search-form") return

        const originalRender = renderEvent.detail.render
        renderEvent.detail.render = (stream) => {
          originalRender(stream)
          requestAnimationFrame(() => {
            const restored =
              document.querySelector("[aria-label='Tag search query']")
            if (restored) {
              restored.value = query
              restored.focus()
            }
          })
        }
        clearTimeout(timeout)
        abortController.abort()
      },
      { signal: abortController.signal }
    )

    form.requestSubmit()
  }
}
