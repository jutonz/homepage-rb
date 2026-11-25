import { BaseController } from "controllers/application"

export default class extends BaseController {
  static values = { value: String, delay: Number }

  connect() {
    this.idleLabel = this.element.textContent
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  async copy() {
    clearTimeout(this.timer)
    try {
      await navigator.clipboard.writeText(this.valueValue)
      this.element.textContent = "Copied"
      this.timer = setTimeout(() => {
        this.element.textContent = this.idleLabel
      }, this.delayValue)
    } catch {
      this.element.textContent = "Copy failed"
    }
  }
}
