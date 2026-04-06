import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
    title: String,
    text: String
  }

  async share() {
    if (navigator.share) {
      try {
        await navigator.share({
          title: this.titleValue,
          text: this.textValue,
          url: this.urlValue
        })
      } catch (err) {
        if (err.name !== "AbortError") {
          this.copyToClipboard()
        }
      }
    } else {
      this.copyToClipboard()
    }
  }

  async copyToClipboard() {
    try {
      await navigator.clipboard.writeText(this.urlValue)
      this.showToast("Link copied!")
    } catch {
      this.showToast("Could not copy link")
    }
  }

  showToast(message) {
    const toast = document.createElement("div")
    toast.textContent = message
    toast.className = "fixed bottom-4 left-1/2 -translate-x-1/2 bg-gray-800 text-white text-sm px-4 py-2 rounded-full shadow-lg z-50 transition-opacity duration-300"
    document.body.appendChild(toast)
    setTimeout(() => {
      toast.style.opacity = "0"
      setTimeout(() => toast.remove(), 300)
    }, 2000)
  }
}
