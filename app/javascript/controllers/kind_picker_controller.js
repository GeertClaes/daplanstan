import { Controller } from "@hotwired/stimulus"

const TRANSPORT_KINDS = new Set(["flight", "car", "train", "ferry"])

export default class extends Controller {
  static targets = ["primaryBtn", "transportPanel", "transportBtn", "kindInput",
                    "moveDefaultIcon", "moveTransportIcon"]

  connect() {
    const kind = this.kindInputTarget.value
    this.transportPanelTarget.hidden = true   // always start collapsed
    this.updateActiveStates(kind)
    if (TRANSPORT_KINDS.has(kind)) {
      this.updateMoveIcon(kind)
    }
  }

  // Called when a primary tile is clicked
  selectPrimary(event) {
    const key = event.currentTarget.dataset.kindKey

    if (key === "move") {
      // Expand the transport sub-row so user can pick a type
      const current = this.kindInputTarget.value
      if (!TRANSPORT_KINDS.has(current)) {
        this.kindInputTarget.value = "flight"
      }
      this.transportPanelTarget.hidden = false
      this.updateActiveStates(this.kindInputTarget.value)
    } else {
      this.kindInputTarget.value = key
      this.transportPanelTarget.hidden = true
      this.resetMoveIcon()
      this.updateActiveStates(key)
    }
  }

  // Called when a transport sub-tile is clicked — collapses sub-row and swaps Move icon
  selectTransport(event) {
    const kind = event.currentTarget.dataset.kindKey
    this.kindInputTarget.value = kind
    this.transportPanelTarget.hidden = true
    this.updateActiveStates(kind)
    if (TRANSPORT_KINDS.has(kind)) {
      this.updateMoveIcon(kind)
    }
  }

  updateActiveStates(kind) {
    const isTransport = TRANSPORT_KINDS.has(kind)
    this.primaryBtnTargets.forEach(btn => {
      const key = btn.dataset.kindKey
      this.setActive(btn, key === "move" ? isTransport : key === kind)
    })
    this.transportBtnTargets.forEach(btn => {
      this.setActive(btn, btn.dataset.kindKey === kind)
    })
  }

  // Show the transport icon matching `kind` inside the Move tile
  updateMoveIcon(kind) {
    if (this.hasMoveDefaultIconTarget) {
      this.moveDefaultIconTarget.hidden = true
    }
    this.moveTransportIconTargets.forEach(span => {
      span.hidden = span.dataset.kind !== kind
    })
  }

  // Restore the walking-man icon in the Move tile
  resetMoveIcon() {
    if (this.hasMoveDefaultIconTarget) {
      this.moveDefaultIconTarget.hidden = false
    }
    this.moveTransportIconTargets.forEach(span => {
      span.hidden = true
    })
  }

  setActive(el, active) {
    if (active) {
      el.dataset.active = "true"
    } else {
      delete el.dataset.active
    }
  }
}
