import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.dialog.addEventListener("close", this.handleClose)
  }

  disconnect() {
    this.dialog.removeEventListener("close", this.handleClose)
  }

  open() {
    this.dialog.showModal()
  }

  close() {
    this.dialog.close()
  }

  handleClose = () => {}

  get dialog() {
    return this.element.querySelector("dialog")
  }
}
