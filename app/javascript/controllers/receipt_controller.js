import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview", "submit"]

  preview(event) {
    const file = event.target.files[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = (e) => {
      if (this.hasPreviewTarget) {
        this.previewTarget.src = e.target.result
        this.previewTarget.classList.remove("hidden")
      }
    }
    reader.readAsDataURL(file)
  }

  submit(event) {
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = true
      this.submitTarget.textContent = "Uploading…"
    }
  }
}
