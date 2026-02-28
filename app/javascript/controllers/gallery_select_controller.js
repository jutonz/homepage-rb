import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { mode: Boolean }
  static targets = ["image"]

  connect() {
    this.updateAllLinks()
  }

  imageTargetConnected(target) {
    const id = target.dataset.imageId?.toString()
    if (id && this.selectedIds.includes(id)) {
      this.addRing(target)
    }
  }

  toggleImage(event) {
    if (!this.modeValue) return
    event.preventDefault()

    const target = event.currentTarget
    const id = target.dataset.imageId?.toString()
    if (!id) return

    const url = new URL(window.location)
    const ids = url.searchParams.getAll("selected_ids[]")

    if (ids.includes(id)) {
      const updated = ids.filter(i => i !== id)
      url.searchParams.delete("selected_ids[]")
      updated.forEach(i => url.searchParams.append("selected_ids[]", i))
      this.removeRing(target)
    } else {
      url.searchParams.append("selected_ids[]", id)
      this.addRing(target)
    }

    history.replaceState(null, "", url.toString())
    this.updateAllLinks()
    this.syncFormInputs()
  }

  handleFrameRender() {
    this.updateAllLinks()
  }

  updateAllLinks() {
    const ids = this.selectedIds
    this.element.querySelectorAll("a[href]").forEach(link => {
      const url = new URL(link.href, window.location)
      url.searchParams.delete("selected_ids[]")
      ids.forEach(id => url.searchParams.append("selected_ids[]", id))
      link.href = url.toString()
    })
  }

  syncFormInputs() {
    const ids = this.selectedIds
    this.element.querySelectorAll("form").forEach(form => {
      form
        .querySelectorAll("input[name='selected_ids[]']")
        .forEach(input => input.remove())
      ids.forEach(id => {
        const input = document.createElement("input")
        input.type = "hidden"
        input.name = "selected_ids[]"
        input.value = id
        form.appendChild(input)
      })
    })
  }

  get selectedIds() {
    if (!this.modeValue) return []
    return new URL(window.location).searchParams.getAll("selected_ids[]")
  }

  addRing(el) {
    el.classList.add("gallery-image--selected")
  }

  removeRing(el) {
    el.classList.remove("gallery-image--selected")
  }
}
