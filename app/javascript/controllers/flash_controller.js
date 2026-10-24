import { BaseController } from "controllers/application"

export default class extends BaseController {
  static values = { delay: Number }

  connect() {
    this.timer = setTimeout(() => this.element.remove(), this.delayValue)
  }

  disconnect() {
    clearTimeout(this.timer)
  }
}
