import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "btn"]

  pick(event) {
    const key = event.currentTarget.dataset.key
    this.inputTarget.value = key
    this.btnTargets.forEach(btn => btn.classList.toggle("btn-active", btn.dataset.key === key))
  }
}
