import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.timeout = setTimeout(() => this.dismiss(), 3500)
  }

  dismiss() {
    this.element.style.transition = "opacity 0.4s ease"
    this.element.style.opacity = "0"
    setTimeout(() => this.element.remove(), 400)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
