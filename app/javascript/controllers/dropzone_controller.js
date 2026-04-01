import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "dropArea",
    "fileInput",
    "fileList",
    "submitButton",
  ]

  connect() {
    this.files = []
    this.blobUrls = []
    this.dragCounter = 0
    this.uploading = false

    this.boundInit =
      this.directUploadInit.bind(this)
    this.boundProgress =
      this.directUploadProgress.bind(this)
    this.boundEnd =
      this.directUploadEnd.bind(this)
    this.boundError =
      this.directUploadError.bind(this)

    document.addEventListener(
      "direct-upload:initialize", this.boundInit
    )
    document.addEventListener(
      "direct-upload:progress", this.boundProgress
    )
    document.addEventListener(
      "direct-upload:end", this.boundEnd
    )
    document.addEventListener(
      "direct-upload:error", this.boundError
    )
  }

  disconnect() {
    document.removeEventListener(
      "direct-upload:initialize", this.boundInit
    )
    document.removeEventListener(
      "direct-upload:progress", this.boundProgress
    )
    document.removeEventListener(
      "direct-upload:end", this.boundEnd
    )
    document.removeEventListener(
      "direct-upload:error", this.boundError
    )
    this.revokeBlobUrls()
  }

  dragEnter(event) {
    event.preventDefault()
    this.dragCounter++
    this.dropAreaTarget.classList.add(
      "dropzone--active"
    )
  }

  dragOver(event) {
    event.preventDefault()
  }

  dragLeave(event) {
    event.preventDefault()
    this.dragCounter = Math.max(
      0, this.dragCounter - 1
    )
    if (this.dragCounter <= 0) {
      this.dropAreaTarget.classList.remove(
        "dropzone--active"
      )
    }
  }

  drop(event) {
    event.preventDefault()
    this.dragCounter = 0
    this.dropAreaTarget.classList.remove(
      "dropzone--active"
    )
    this.addFiles(event.dataTransfer.files)
  }

  openFilePicker() {
    if (this.uploading) return
    this.fileInputTarget.click()
  }

  filesSelected() {
    this.addFiles(this.fileInputTarget.files)
  }

  addFiles(fileList) {
    if (this.uploading) return
    for (const file of fileList) {
      this.files.push(file)
    }
    this.syncFileInput()
    this.renderFileList()
  }

  removeFile(event) {
    const index = parseInt(
      event.currentTarget.dataset.index,
      10
    )
    this.files.splice(index, 1)
    this.syncFileInput()
    this.renderFileList()
  }

  handleSubmit() {
    if (this.files.length === 0) return

    this.uploading = true
    this.submitButtonTarget.disabled = true
    this.submitButtonTarget.textContent =
      "Uploading..."

    this.fileListTarget
      .querySelectorAll("[data-remove-btn]")
      .forEach((btn) => btn.remove())
  }

  directUploadInit(event) {
    const { id, file } = event.detail
    const row = this.findRowByFile(file)
    if (!row) return

    row.dataset.uploadId = id
    row.classList.add(
      "dropzone__file-row--uploading"
    )
    const bar = row.querySelector(
      ".dropzone__progress"
    )
    if (bar) bar.classList.remove("hidden")
  }

  directUploadProgress(event) {
    const row = this.fileRowByUploadId(
      event.detail.id
    )
    if (!row) return

    const bar = row.querySelector(
      ".dropzone__progress-bar"
    )
    if (bar) {
      bar.style.width =
        `${event.detail.progress}%`
    }
  }

  directUploadEnd(event) {
    const row = this.fileRowByUploadId(
      event.detail.id
    )
    if (!row) return

    row.classList.remove(
      "dropzone__file-row--uploading"
    )
    row.classList.add(
      "dropzone__file-row--complete"
    )

    const bar = row.querySelector(
      ".dropzone__progress"
    )
    if (bar) bar.classList.add("hidden")

    const status = row.querySelector(
      "[data-status]"
    )
    if (status) status.textContent = "\u2713"
  }

  directUploadError(event) {
    event.preventDefault()
    const row = this.fileRowByUploadId(
      event.detail.id
    )
    if (!row) return

    row.classList.remove(
      "dropzone__file-row--uploading"
    )
    row.classList.add(
      "dropzone__file-row--error"
    )

    const status = row.querySelector(
      "[data-status]"
    )
    if (status) status.textContent = "Failed"

    this.recoverFromError()
  }

  recoverFromError() {
    this.uploading = false
    this.submitButtonTarget.disabled = false
    this.submitButtonTarget.textContent =
      "Create Bulk upload"

    this.fileListTarget
      .querySelectorAll(".dropzone__file-row")
      .forEach((row) => {
        if (row.dataset.uploadId) return
        this.addRemoveButton(row)
      })
  }

  // Private

  syncFileInput() {
    const dt = new DataTransfer()
    this.files.forEach((file) => dt.items.add(file))
    this.fileInputTarget.files = dt.files
  }

  renderFileList() {
    this.revokeBlobUrls()
    const container = this.fileListTarget
    container.innerHTML = ""

    this.files.forEach((file, index) => {
      const row = document.createElement("div")
      row.classList.add("dropzone__file-row")
      row.dataset.fileIndex = index
      row.dataset.fileName = file.name
      row.dataset.fileSize = file.size

      // Thumbnail
      const thumb = document.createElement("div")
      thumb.classList.add(
        "shrink-0", "w-12", "h-12",
        "rounded", "overflow-hidden",
        "bg-gray-200", "flex",
        "items-center", "justify-center"
      )

      if (file.type.startsWith("image/")) {
        const img = document.createElement("img")
        const url = URL.createObjectURL(file)
        this.blobUrls.push(url)
        img.src = url
        img.classList.add(
          "w-full", "h-full", "object-cover"
        )
        thumb.appendChild(img)
      } else {
        thumb.textContent = "\uD83D\uDCC4"
      }
      row.appendChild(thumb)

      // File info
      const info = document.createElement("div")
      info.classList.add("flex-1", "min-w-0")

      const name = document.createElement("div")
      name.classList.add(
        "text-sm", "font-medium", "truncate"
      )
      name.textContent = file.name
      info.appendChild(name)

      const size = document.createElement("div")
      size.classList.add(
        "text-xs", "text-gray-500"
      )
      size.textContent = this.formatSize(file.size)
      info.appendChild(size)

      row.appendChild(info)

      // Progress bar (hidden until upload starts)
      const progress =
        document.createElement("div")
      progress.classList.add(
        "dropzone__progress", "hidden"
      )
      const bar = document.createElement("div")
      bar.classList.add("dropzone__progress-bar")
      bar.style.width = "0%"
      progress.appendChild(bar)
      row.appendChild(progress)

      // Status indicator
      const status =
        document.createElement("span")
      status.dataset.status = ""
      status.classList.add(
        "text-sm", "text-gray-400", "shrink-0"
      )
      row.appendChild(status)

      this.addRemoveButton(row)

      container.appendChild(row)
    })
  }

  addRemoveButton(row) {
    if (row.querySelector("[data-remove-btn]")) {
      return
    }
    const index = row.dataset.fileIndex
    const fileName = row.dataset.fileName
    const btn =
      document.createElement("button")
    btn.type = "button"
    btn.dataset.removeBtn = ""
    btn.dataset.index = index
    btn.dataset.action =
      "click->dropzone#removeFile"
    btn.classList.add(
      "text-gray-400",
      "hover:text-red-500",
      "text-lg",
      "leading-none",
      "shrink-0",
      "cursor-pointer"
    )
    btn.textContent = "\u00D7"
    btn.setAttribute(
      "aria-label", `Remove ${fileName}`
    )
    row.appendChild(btn)
  }

  findRowByFile(file) {
    return this.fileListTarget.querySelector(
      `[data-file-name="${CSS.escape(file.name)}"]` +
      `[data-file-size="${file.size}"]` +
      `:not([data-upload-id])`
    )
  }

  fileRowByUploadId(id) {
    return this.fileListTarget.querySelector(
      `[data-upload-id="${id}"]`
    )
  }

  formatSize(bytes) {
    if (bytes < 1024) return `${bytes} B`
    if (bytes < 1024 * 1024) {
      return `${(bytes / 1024).toFixed(1)} KB`
    }
    return `${(bytes / (1024 * 1024)).toFixed(1)} MB`
  }

  revokeBlobUrls() {
    this.blobUrls.forEach(
      (url) => URL.revokeObjectURL(url)
    )
    this.blobUrls = []
  }
}
