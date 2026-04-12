import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values  = { active: String }

  connect() {
    const initial = new URLSearchParams(window.location.search).get("tab") || this.activeValue || this.tabTargets[0]?.dataset.tab
    this.show(initial)
  }

  switch(event) {
    const tab = event.currentTarget.dataset.tab
    this.show(tab)
    const url = new URL(window.location)
    url.searchParams.set("tab", tab)
    history.replaceState({}, "", url)
  }

  show(tab) {
    this.tabTargets.forEach(t => {
      t.classList.toggle("tab-active", t.dataset.tab === tab)
    })
    this.panelTargets.forEach(p => {
      p.classList.toggle("hidden", p.dataset.tab !== tab)
    })
  }
}
