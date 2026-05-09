import { Controller } from "@hotwired/stimulus"

const SELECTED = ["!bg-primary/15", "ring-1", "ring-primary/30", "ring-inset"]

export default class extends Controller {
  static targets = ["item", "row", "filterBtn", "statusBtn", "dateGroup"]

  activeKind   = "all"
  activeStatus = "all"

  select(event) {
    const row       = event.currentTarget
    const wasSelected = row.dataset.selected === "true"
    const map       = document.getElementById("trip-map")

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
    const btn = event.currentTarget
    this.activeKind = btn.dataset.kind

    this.filterBtnTargets.forEach(b => {
      const active = b.dataset.kind === this.activeKind
      b.classList.toggle("bg-primary",          active)
      b.classList.toggle("text-primary-content", active)
      b.classList.toggle("bg-base-300",          !active)
      b.classList.toggle("text-base-content/60", !active)
    })

    this.#applyFilters()
  }

  filterStatus(event) {
    const btn = event.currentTarget
    this.activeStatus = btn.dataset.status

    this.statusBtnTargets.forEach(b => {
      const active = b.dataset.status === this.activeStatus
      b.classList.toggle("bg-primary",          active)
      b.classList.toggle("text-primary-content", active)
      b.classList.toggle("bg-base-300",          !active)
      b.classList.toggle("text-base-content/60", !active)
      // restore idea/confirmed icon tint when inactive
      if (!active) {
        if (b.dataset.status === "idea")      b.classList.add("text-base-content/40")
        if (b.dataset.status === "confirmed") b.classList.add("text-primary")
      }
      if (active) {
        b.classList.remove("text-base-content/40", "text-primary")
      }
    })

    this.#applyFilters()
  }

  #applyFilters() {
    this.rowTargets.forEach(row => {
      const kindMatch   = this.activeKind   === "all" || row.dataset.kind   === this.activeKind
      const statusMatch = this.activeStatus === "all" || row.dataset.status === this.activeStatus
      row.classList.toggle("hidden", !(kindMatch && statusMatch))
    })

    this.dateGroupTargets.forEach(group => {
      const rows = group.querySelectorAll("[data-timeline-target~='row']")
      const anyVisible = Array.from(rows).some(r => !r.classList.contains("hidden"))
      group.classList.toggle("hidden", !anyVisible)
    })
  }
}
