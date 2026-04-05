import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    mealId: Number,
    suggestionIndex: Number,
    favorited: Boolean
  }

  toggle() {
    this.favoritedValue = !this.favoritedValue
    this.updateIcon()

    const token = document.querySelector('meta[name="csrf-token"]').content

    fetch(`/meals/${this.mealIdValue}/favorite`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token
      },
      body: JSON.stringify({ suggestion_index: this.suggestionIndexValue })
    }).then(response => {
      if (!response.ok) {
        this.favoritedValue = !this.favoritedValue
        this.updateIcon()
      }
    }).catch(() => {
      this.favoritedValue = !this.favoritedValue
      this.updateIcon()
    })
  }

  updateIcon() {
    const filled = this.element.querySelector('[data-heart="filled"]')
    const outline = this.element.querySelector('[data-heart="outline"]')

    if (this.favoritedValue) {
      filled.classList.remove("hidden")
      outline.classList.add("hidden")
    } else {
      filled.classList.add("hidden")
      outline.classList.remove("hidden")
    }
  }

  connect() {
    this.updateIcon()
  }
}
