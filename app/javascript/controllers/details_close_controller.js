import { Controller } from "@hotwired/stimulus"

// Closes a <details> element when the user clicks outside it or navigates away.
export default class extends Controller {
  connect() {
    this._outside = (e) => {
      if (!this.element.contains(e.target)) this.element.open = false
    }
    document.addEventListener("click", this._outside)
    document.addEventListener("turbo:before-visit", this._close)
  }

  disconnect() {
    document.removeEventListener("click", this._outside)
    document.removeEventListener("turbo:before-visit", this._close)
  }

  _close = () => { this.element.open = false }
}
