import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "dialog",
    "tagIdInput",
    "selectedTagName",
    "confirmButton",
    "selectedIdsContainer",
  ]

  open() {
    this.syncSelectedIds()
    this.clearTagSelection()
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  selectTag(event) {
    const tagId = event.currentTarget.dataset.tagId
    const tagName = event.currentTarget.dataset.tagName
    this.tagIdInputTarget.value = tagId
    this.selectedTagNameTarget.textContent = tagName
    this.confirmButtonTarget.disabled = false
  }

  syncSelectedIds() {
    const ids = new URL(window.location)
      .searchParams.getAll("selected_ids[]")
    const container = this.selectedIdsContainerTarget
    container.innerHTML = ""
    ids.forEach(id => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "bulk_tag[image_ids][]"
      input.value = id
      container.appendChild(input)
    })
  }

  clearTagSelection() {
    this.tagIdInputTarget.value = ""
    this.selectedTagNameTarget.textContent = "None selected"
    this.confirmButtonTarget.disabled = true
  }
}
