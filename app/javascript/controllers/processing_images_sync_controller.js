import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static values = {
    galleryId: Number,
    interval: { type: Number, default: 15000 },
  }

  connect() {
    this.consumer = createConsumer()
    this.subscription =
      this.consumer.subscriptions.create(
        {
          channel: "Galleries::ProcessingImagesChannel",
          gallery_id: this.galleryIdValue,
        },
        {
          received: (data) => {
            this.handleReceived(data)
          },
        }
      )
    this.startPolling()
  }

  disconnect() {
    this.stopPolling()
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
    if (this.consumer) {
      this.consumer.disconnect()
    }
  }

  handleReceived(data) {
    if (data.action === "reconcile") {
      this.reconcile(data.unprocessed_ids)
    }
  }

  reconcile(unprocessedIds) {
    const keepIds = new Set(
      unprocessedIds.map((id) => `processing_image_${id}`)
    )
    const elements = this.element.querySelectorAll(
      "[data-role='processing-image']"
    )

    elements.forEach((el) => {
      if (!keepIds.has(el.id)) {
        el.remove()
      }
    })
  }

  startPolling() {
    this.timer = setInterval(() => {
      if (this.subscription) {
        this.subscription.perform("sync")
      }
    }, this.intervalValue)
  }

  stopPolling() {
    if (this.timer) {
      clearInterval(this.timer)
      this.timer = null
    }
  }
}
