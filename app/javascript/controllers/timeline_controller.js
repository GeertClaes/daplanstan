import { Controller } from "@hotwired/stimulus"

const SELECTED = ["!bg-primary/15", "ring-1", "ring-primary/30", "ring-inset"]

export default class extends Controller {
  static targets = ["item"]

  select(event) {
    const row       = event.currentTarget
    const wasSelected = row.dataset.selected === "true"
    const map       = document.getElementById("trip-map")

    // Clear all selections
    this.itemTargets.forEach(item => {
      item.classList.remove(...SELECTED)
      item.dataset.selected = "false"
    })

    if (wasSelected) {
      // Second tap on same stop — zoom back out
      if (map) map.dispatchEvent(new CustomEvent("map:reset", { bubbles: true }))
    } else {
      // First tap — highlight row and zoom map to this stop
      row.classList.add(...SELECTED)
      row.dataset.selected = "true"
      if (map && row.dataset.lat) {
        map.dispatchEvent(new CustomEvent("map:locate", {
          detail: { lat: parseFloat(row.dataset.lat), lng: parseFloat(row.dataset.lng), id: row.dataset.itemId },
          bubbles: true
        }))
      }
    }
  }
}
