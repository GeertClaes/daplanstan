import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "input", "confirm"]
  static values = { title: String }

  open() {
    this.inputTarget.value = ""
    this.confirmTarget.disabled = true
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  check() {
    this.confirmTarget.disabled = this.inputTarget.value.trim() !== this.titleValue
  }
}
