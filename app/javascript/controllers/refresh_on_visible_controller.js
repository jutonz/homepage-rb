import { BaseController } from "controllers/application"

export default class extends BaseController {
  connect() {
    this.boundRefresh = this.refresh.bind(this)
    document.addEventListener("visibilitychange", this.boundRefresh)
  }

  disconnect() {
    document.removeEventListener("visibilitychange", this.boundRefresh)
  }

  refresh() {
    if (document.visibilityState !== "visible") return
    if (typeof this.element.reload !== "function") return
    this.element.reload()
  }
}
