import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { threshold: { type: Number, default: 80 } }

  connect() {
    this.startY = null
    this.pullDistance = 0
    this.scrollEl = null
    this.indicator = this.#createIndicator()
    document.body.prepend(this.indicator)

    this._onStart = this.#onStart.bind(this)
    this._onMove  = this.#onMove.bind(this)
    this._onEnd   = this.#onEnd.bind(this)

    document.addEventListener("touchstart", this._onStart, { passive: true })
    document.addEventListener("touchmove",  this._onMove,  { passive: false })
    document.addEventListener("touchend",   this._onEnd,   { passive: true })
  }

  disconnect() {
    document.removeEventListener("touchstart", this._onStart)
    document.removeEventListener("touchmove",  this._onMove)
    document.removeEventListener("touchend",   this._onEnd)
    this.indicator.remove()
  }

  #onStart(event) {
    const el = this.#scrollableParent(event.target)
    const scrollTop = el ? el.scrollTop : window.scrollY
    if (scrollTop > 0) return

    this.scrollEl = el
    this.startY = event.touches[0].clientY
    this.pullDistance = 0
  }

  #onMove(event) {
    if (this.startY === null) return

    const scrollTop = this.scrollEl ? this.scrollEl.scrollTop : window.scrollY
    if (scrollTop > 0) { this.startY = null; this.#hide(); return }

    const delta = event.touches[0].clientY - this.startY
    if (delta <= 0) { this.startY = null; this.#hide(); return }

    this.pullDistance = delta
    if (delta > 8) event.preventDefault()

    const pct   = Math.min(delta / this.thresholdValue, 1)
    const ready = delta >= this.thresholdValue
    this.#show(pct, ready)
  }

  #onEnd() {
    if (this.startY === null) return
    const d = this.pullDistance
    this.startY = null
    this.pullDistance = 0

    if (d >= this.thresholdValue) {
      this.#triggerRefresh()
    } else {
      this.#hide()
    }
  }

  #scrollableParent(el) {
    while (el && el !== document.documentElement) {
      const { overflowY } = getComputedStyle(el)
      if ((overflowY === "auto" || overflowY === "scroll") && el.scrollHeight > el.clientHeight) {
        return el
      }
      el = el.parentElement
    }
    return null
  }

  #createIndicator() {
    const el = document.createElement("div")
    Object.assign(el.style, {
      position:     "fixed",
      top:          "0",
      left:         "50%",
      translate:    "-50%",
      zIndex:       "9999",
      width:        "36px",
      height:       "36px",
      borderRadius: "50%",
      background:   "var(--color-base-200)",
      border:       "1px solid color-mix(in oklab, var(--color-base-content) 12%, transparent)",
      boxShadow:    "0 2px 8px rgb(0 0 0 / 0.15)",
      display:      "flex",
      alignItems:   "center",
      justifyContent: "center",
      opacity:      "0",
      transform:    "translateY(-44px)",
      color:        "var(--color-base-content)",
      pointerEvents: "none",
    })
    el.innerHTML = this.#arrowSvg()
    return el
  }

  #show(pct, ready) {
    const translateY = Math.round(pct * 44) - 44
    this.indicator.style.opacity   = pct
    this.indicator.style.transform = `translateY(${translateY}px)`
    this.indicator.style.color     = ready
      ? "var(--color-primary)"
      : "var(--color-base-content)"
    this.indicator.querySelector("svg").style.transform = `rotate(${pct * 180}deg)`
  }

  #hide() {
    this.indicator.style.opacity   = "0"
    this.indicator.style.transform = "translateY(-44px)"
  }

  #triggerRefresh() {
    this.indicator.style.opacity   = "1"
    this.indicator.style.transform = "translateY(8px)"
    this.indicator.style.color     = "var(--color-primary)"
    this.indicator.innerHTML       = this.#spinnerSvg()
    window.location.reload()
  }

  #arrowSvg() {
    return `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24"
      fill="none" stroke="currentColor" stroke-width="2.5"
      stroke-linecap="round" stroke-linejoin="round">
      <path d="M12 5v14M5 12l7 7 7-7"/>
    </svg>`
  }

  #spinnerSvg() {
    return `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24"
      fill="none" stroke="currentColor" stroke-width="2.5"
      stroke-linecap="round" stroke-linejoin="round"
      style="animation: spin 0.7s linear infinite">
      <path d="M21 12a9 9 0 11-6.219-8.56"/>
    </svg>
    <style>@keyframes spin { to { transform: rotate(360deg) } }</style>`
  }
}
