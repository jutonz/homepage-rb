import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }
  static targets = ["progress"]

  connect() {
    this.uploadsDone = false

    // Fire individual requests once Active Storage finishes all direct uploads
    this.element.addEventListener(
      "direct-uploads:end",
      this.handleUploadsEnd.bind(this)
    )

    // Prevent the form resubmission that Active Storage triggers after uploads
    this.element.addEventListener(
      "submit",
      this.handleSubmit.bind(this)
    )
  }

  handleSubmit(event) {
    // First submit: let it through so Active Storage can run its direct uploads.
    // Second submit (Active Storage resubmits after uploads complete): block it.
    if (this.uploadsDone) {
      event.preventDefault()
    }
  }

  handleUploadsEnd() {
    this.uploadsDone = true
    this.progressTarget.classList.remove("hidden")

    const tagIds = Array.from(
      this.element.querySelectorAll(
        "[name='bulk_upload[tag_ids][]']"
      )
    ).map((el) => el.value)

    const signedIds = Array.from(
      this.element.querySelectorAll(
        "input[name='bulk_upload[files][]'][type=hidden]"
      )
    ).map((el) => el.value)

    signedIds.forEach((signedId) => this.uploadOne(signedId, tagIds))
  }

  async uploadOne(signedId, tagIds) {
    const fd = new FormData()
    fd.append("bulk_upload[signed_id]", signedId)
    tagIds.forEach((id) => fd.append("bulk_upload[tag_ids][]", id))

    const csrfToken = document
      .querySelector("meta[name=csrf-token]")
      ?.getAttribute("content")

    const resp = await fetch(this.urlValue, {
      method: "POST",
      headers: {
        Accept: "text/vnd.turbo-stream.html",
        "X-CSRF-Token": csrfToken,
      },
      body: fd,
    })

    if (resp.ok) {
      Turbo.renderStreamMessage(await resp.text())
    }
  }
}
