const KB = 1024
const MB = KB * 1024
const GB = MB * 1024
const WINDOW_MS = 5000
const WARMUP_MS = 500
const DASH = "—"

export function formatSize(bytes) {
  if (bytes < KB) return `${bytes} B`
  if (bytes < MB) return `${(bytes / KB).toFixed(1)} KB`
  if (bytes < GB) return `${(bytes / MB).toFixed(1)} MB`
  return `${(bytes / GB).toFixed(1)} GB`
}

export function formatEta(seconds) {
  const total = Math.ceil(seconds)
  if (total < 60) return `${total}s`
  const pad = (n) => String(n).padStart(2, "0")
  if (total < 3600) {
    return `${Math.floor(total / 60)}m ${pad(total % 60)}s`
  }
  const minutes = Math.floor((total % 3600) / 60)
  return `${Math.floor(total / 3600)}h ${pad(minutes)}m`
}

export class UploadStats {
  constructor(size, now = () => performance.now()) {
    this.size = size
    this.now = now
    this.startedAt = now()
    this.samples = [{ at: this.startedAt, loaded: 0 }]
  }

  record(loaded) {
    const at = this.now()
    this.samples.push({ at, loaded })
    while (this.samples[0].at < at - WINDOW_MS) {
      this.samples.shift()
    }
  }

  get loaded() {
    return this.samples[this.samples.length - 1].loaded
  }

  rate() {
    const latest = this.samples[this.samples.length - 1]
    if (latest.at - this.startedAt < WARMUP_MS) return null
    const oldest = this.samples[0]
    const seconds = (latest.at - oldest.at) / 1000
    if (seconds <= 0) return null
    return (latest.loaded - oldest.loaded) / seconds
  }

  summary() {
    const rate = this.rate()
    const rateText = rate ? `${formatSize(Math.round(rate))}/s` : DASH
    const etaText = rate
      ? formatEta((this.size - this.loaded) / rate)
      : DASH
    return `${this.bytesText()} · ${rateText} · ETA: ${etaText}`
  }

  bytesText() {
    return `${formatSize(this.loaded)} of ${formatSize(this.size)}`
  }
}
