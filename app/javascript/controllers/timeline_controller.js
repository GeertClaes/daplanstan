import { Controller } from "@hotwired/stimulus"

const SELECTED = ["!bg-primary/15", "ring-1", "ring-primary/30", "ring-inset"]

export default class extends Controller {
  static targets = ["item", "row", "filterBtn", "dateGroup"]

  activeFilter = "all"

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
      if (map) map.dispatchEvent(new CustomEvent("map:reset", { bubbles: true }))
    } else {
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

  filter(event) {
    const btn  = event.currentTarget
    const kind = btn.dataset.kind

    this.activeFilter = kind

    // Update button active styles
    this.filterBtnTargets.forEach(b => {
      const active = b.dataset.kind === kind
      b.classList.toggle("bg-primary", active)
      b.classList.toggle("text-primary-content", active)
      b.classList.toggle("bg-base-300", !active)
      b.classList.toggle("text-base-content/60", !active)
    })

    // Show/hide rows
    this.rowTargets.forEach(row => {
      const match = kind === "all" || row.dataset.kind === kind
      row.classList.toggle("hidden", !match)
    })

    // Hide date group headers that have no visible rows
    this.dateGroupTargets.forEach(group => {
      const rows = group.querySelectorAll("[data-timeline-target~='row']")
      const anyVisible = Array.from(rows).some(r => !r.classList.contains("hidden"))
      group.classList.toggle("hidden", !anyVisible)
    })
  }
}
