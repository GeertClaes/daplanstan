import { Controller } from "@hotwired/stimulus"

// Reads a selected .json file into the textarea so the user doesn't have to paste manually.
export default class extends Controller {
  static targets = ["input", "textarea", "label"]

  load() {
    const file = this.inputTarget.files[0]
    if (!file) return
    this.labelTarget.textContent = file.name
    const reader = new FileReader()
    reader.onload = (e) => { this.textareaTarget.value = e.target.result }
    reader.readAsText(file)
  }
}
