import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    mealId: Number,
    suggestionIndex: Number,
    hasKidContribution: Boolean,
    existingRecipeRating: Number,
    existingKidTipRating: Number,
    editing: Boolean
  }

  static targets = ["modal", "backdrop", "recipeStars", "kidStars", "kidSection", "buttonText", "saveButton", "hint"]

  connect() {
    this.recipeRating = this.existingRecipeRatingValue || 0
    this.kidTipRating = this.existingKidTipRatingValue || 0
    this.updateButtonState()
    this.updateSaveButton()
  }

  open() {
    this.renderStars(this.recipeStarsTarget, this.recipeRating, "recipe")
    if (this.hasKidContributionValue) {
      this.kidSectionTarget.classList.remove("hidden")
      this.renderStars(this.kidStarsTarget, this.kidTipRating, "kid")
    } else {
      this.kidSectionTarget.classList.add("hidden")
    }
    this.modalTarget.classList.remove("hidden")
    requestAnimationFrame(() => {
      this.backdropTarget.classList.remove("opacity-0")
      this.modalTarget.querySelector("[data-panel]").classList.remove("opacity-0", "scale-95")
      this.modalTarget.querySelector("[data-panel]").classList.add("opacity-100", "scale-100")
    })
  }

  close() {
    this.backdropTarget.classList.add("opacity-0")
    this.modalTarget.querySelector("[data-panel]").classList.add("opacity-0", "scale-95")
    this.modalTarget.querySelector("[data-panel]").classList.remove("opacity-100", "scale-100")
    setTimeout(() => this.modalTarget.classList.add("hidden"), 200)
  }

  closeBackdrop(event) {
    if (event.target === this.backdropTarget) this.close()
  }

  selectRecipeStar(event) {
    this.recipeRating = parseInt(event.currentTarget.dataset.rating)
    this.renderStars(this.recipeStarsTarget, this.recipeRating, "recipe")
    this.updateSaveButton()
  }

  selectKidStar(event) {
    this.kidTipRating = parseInt(event.currentTarget.dataset.rating)
    this.renderStars(this.kidStarsTarget, this.kidTipRating, "kid")
  }

  hoverRecipeStar(event) {
    const rating = parseInt(event.currentTarget.dataset.rating)
    this.previewStars(this.recipeStarsTarget, rating)
  }

  hoverKidStar(event) {
    const rating = parseInt(event.currentTarget.dataset.rating)
    this.previewStars(this.kidStarsTarget, rating)
  }

  resetRecipeHover() {
    this.renderStars(this.recipeStarsTarget, this.recipeRating, "recipe")
  }

  resetKidHover() {
    this.renderStars(this.kidStarsTarget, this.kidTipRating, "kid")
  }

  async save() {
    if (this.recipeRating === 0) {
      this.hintTarget.classList.remove("hidden")
      return
    }
    this.hintTarget.classList.add("hidden")

    const token = document.querySelector('meta[name="csrf-token"]').content
    const body = { suggestion_index: this.suggestionIndexValue, recipe_rating: this.recipeRating }
    if (this.hasKidContributionValue && this.kidTipRating > 0) {
      body.kid_tip_rating = this.kidTipRating
    }

    try {
      const response = await fetch(`/meals/${this.mealIdValue}/rate`, {
        method: "POST",
        headers: { "Content-Type": "application/json", "X-CSRF-Token": token },
        body: JSON.stringify(body)
      })

      if (response.ok) {
        this.editingValue = true
        this.existingRecipeRatingValue = this.recipeRating
        if (this.kidTipRating > 0) this.existingKidTipRatingValue = this.kidTipRating
        this.updateButtonState()
        this.close()
        this.showToast("Dinner Logged!")
      } else {
        const data = await response.json().catch(() => ({}))
        this.showToast(data.error || "Something went wrong")
      }
    } catch {
      this.showToast("Something went wrong")
    }
  }

  updateButtonState() {
    if (this.editingValue) {
      this.buttonTextTarget.textContent = "✓ Edit My Review"
      const button = this.buttonTextTarget.closest("button")
      button.classList.remove("border-orange-400", "text-orange-500", "hover:bg-orange-50")
      button.classList.add("border-green-500", "text-green-600", "hover:bg-green-50")
    }
  }

  updateSaveButton() {
    const disabled = this.recipeRating === 0
    this.saveButtonTarget.disabled = disabled
    if (disabled) {
      this.saveButtonTarget.classList.add("opacity-50", "cursor-not-allowed")
      this.saveButtonTarget.classList.remove("hover:bg-orange-600", "cursor-pointer")
    } else {
      this.saveButtonTarget.classList.remove("opacity-50", "cursor-not-allowed")
      this.saveButtonTarget.classList.add("hover:bg-orange-600", "cursor-pointer")
      if (this.hasHintTarget) this.hintTarget.classList.add("hidden")
    }
  }

  renderStars(container, rating, type) {
    const action = type === "recipe" ? "selectRecipeStar" : "selectKidStar"
    const hoverAction = type === "recipe" ? "hoverRecipeStar" : "hoverKidStar"
    const resetAction = type === "recipe" ? "resetRecipeHover" : "resetKidHover"

    container.innerHTML = Array.from({ length: 5 }, (_, i) => {
      const n = i + 1
      const filled = n <= rating
      return `<button type="button" data-rating="${n}"
        data-action="click->rating#${action} mouseenter->rating#${hoverAction} mouseleave->rating#${resetAction}"
        class="cursor-pointer transition-transform hover:scale-110 focus:outline-none">
        <svg class="w-8 h-8" viewBox="0 0 24 24" fill="${filled ? "#f97316" : "none"}" stroke="#f97316" stroke-width="1.5">
          <path stroke-linecap="round" stroke-linejoin="round" d="M11.48 3.499a.562.562 0 0 1 1.04 0l2.125 5.111a.563.563 0 0 0 .475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 0 0-.182.557l1.285 5.385a.562.562 0 0 1-.84.61l-4.725-2.885a.562.562 0 0 0-.586 0L6.982 20.54a.562.562 0 0 1-.84-.61l1.285-5.386a.562.562 0 0 0-.182-.557l-4.204-3.602a.562.562 0 0 1 .321-.988l5.518-.442a.563.563 0 0 0 .475-.345L11.48 3.5Z" />
        </svg>
      </button>`
    }).join("")
  }

  previewStars(container, hoverRating) {
    container.querySelectorAll("button").forEach((btn) => {
      const n = parseInt(btn.dataset.rating)
      const svg = btn.querySelector("svg")
      svg.setAttribute("fill", n <= hoverRating ? "#f97316" : "none")
    })
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
