import { Controller } from "@hotwired/stimulus"

const messages = [
  "Raiding the spice rack...",
  "Arguing with the garlic press...",
  "Consulting a very opinionated Italian grandmother...",
  "Taste-testing in our imagination...",
  "Convincing the oven to preheat...",
  "Negotiating with picky eaters...",
  "Flipping through 10,000 cookbooks...",
  "Asking the fridge for its opinion...",
  "Julienning the algorithms...",
  "Simmering up something good...",
  "Putting on our apron...",
  "Debating whether cilantro is good or evil...",
  "Sharpening the knives (figuratively)...",
  "Whispering sweet nothings to the sourdough...",
  "Calculating the perfect cheese-to-sauce ratio...",
]

export default class extends Controller {
  static targets = ["form", "overlay", "message"]

  submit() {
    this.overlayTarget.classList.remove("hidden")
    this.cycleMessages()
  }

  cycleMessages() {
    const shuffled = messages.sort(() => Math.random() - 0.5)
    let index = 0

    this.messageTarget.textContent = shuffled[index]

    this.interval = setInterval(() => {
      index = (index + 1) % shuffled.length
      this.messageTarget.style.opacity = 0
      setTimeout(() => {
        this.messageTarget.textContent = shuffled[index]
        this.messageTarget.style.opacity = 1
      }, 300)
    }, 3000)
  }

  disconnect() {
    if (this.interval) clearInterval(this.interval)
  }
}
