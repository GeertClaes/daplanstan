import { Controller } from "@hotwired/stimulus"

const HEIGHTS = {
  peek: "144px",
  half: "55vh",
  full:  "88vh"
}
const STATES = ["peek", "half", "full"]

export default class extends Controller {
  connect() {
    this.setState("peek")
  }

  // Tap the handle to cycle through states
  cycle() {
    const idx = STATES.indexOf(this.current)
    this.setState(STATES[(idx + 1) % STATES.length])
  }

  // Allow timeline items to collapse the sheet so the map is visible
  peek() {
    this.setState("peek")
  }

  setState(state) {
    this.current = state
    this.element.style.height = HEIGHTS[state]
  }
}
