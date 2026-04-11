// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Smooth directional transitions via the View Transitions API.
// 1. turbo:click — reads data-turbo-direction from the clicked link and
//    stores it on <html> so CSS can pick the right slide direction.
// 2. turbo:before-render — wraps the DOM swap in startViewTransition.
// 3. turbo:render — cleans up the direction attribute.
document.addEventListener("turbo:click", (event) => {
  const el = event.target.closest("[data-turbo-direction]")
  const dir = el?.dataset.turboDirection ?? "forward"
  document.documentElement.dataset.turboDirection = dir
})

document.addEventListener("turbo:before-render", (event) => {
  if (!document.startViewTransition) return
  event.preventDefault()
  const transition = document.startViewTransition(() => event.detail.resume())
  // Clean up direction AFTER the animation finishes, not at turbo:render
  // (turbo:render fires immediately at DOM swap, before CSS animations complete)
  transition.finished.then(() => {
    delete document.documentElement.dataset.turboDirection
  })
})
