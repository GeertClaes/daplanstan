import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "navItem"]

  connect() {
    const tab = new URLSearchParams(window.location.search).get("tab") || "itinerary"
    this.activeTab = tab
    this.show(tab)

    // After a Turbo morph refresh the panels container is preserved (data-turbo-permanent)
    // but the tab bar / bottom nav are re-morphed and lose their active classes.
    // Re-apply the active state whenever Turbo renders.
    this._onRender = () => this.show(this.activeTab)
    document.addEventListener("turbo:render", this._onRender)
  }

  disconnect() {
    document.removeEventListener("turbo:render", this._onRender)
  }

  switch(event) {
    const tab = event.currentTarget.dataset.tab
    this.activeTab = tab
    this.show(tab)
    const url = new URL(window.location)
    url.searchParams.set("tab", tab)
    history.pushState({}, "", url)
  }

  show(tab) {
    this.panelTargets.forEach(p => {
      const visible   = p.dataset.tab === tab
      const wasHidden = p.style.display === "none"
      p.style.display = visible ? "" : "none"
      // Only fire map:resize when the itinerary panel transitions hidden→visible.
      // Turbo morph also calls show() via turbo:render while the panel is already
      // visible — skipping the event there prevents fitBounds() from resetting the
      // user's zoom/pan position on every live-update.
      if (visible && wasHidden && tab === "itinerary") {
        const mapEl = p.querySelector("[data-controller='map']")
        if (mapEl) mapEl.dispatchEvent(new CustomEvent("map:resize"))
      }
    })

    this.navItemTargets.forEach(n => {
      const active   = n.dataset.tab === tab
      const desktop  = n.dataset.navScope === "desktop"

      // Desktop segmented pill: tinted primary chip when active
      n.classList.toggle("bg-primary/20",        active && desktop)
      n.classList.toggle("text-primary",         active)
      n.classList.toggle("font-semibold",        active)
      n.classList.toggle("text-base-content/50", !active && desktop)
      n.classList.toggle("text-base-content/40", !active && !desktop)
    })
  }
}
