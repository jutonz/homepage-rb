import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.removeAttribute("disabled")
  }

  enter(event) {
    event.preventDefault()

    const url = new URL(window.location.href)
    url.searchParams.set("select", "true")
    this.visit(url)
  }

  exit(event) {
    event.preventDefault()

    const url = new URL(window.location.href)
    url.searchParams.delete("select")
    url.searchParams.delete("selected_ids[]")
    this.visit(url)
  }

  visit(url) {
    window.Turbo.visit(url.toString())
  }
}
