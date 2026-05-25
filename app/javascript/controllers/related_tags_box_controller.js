import { Controller } from "@hotwired/stimulus"

// Ensures only the most recently added tag shows a "Related to" box, and
// handles dismissing the box via the ✕ button.
export default class extends Controller {
  connect() {
    document
      .querySelectorAll("[data-role='related-tags-box']")
      .forEach((box) => {
        if (box !== this.element) box.remove()
      })
  }

  dismiss() {
    this.element.remove()
  }
}
